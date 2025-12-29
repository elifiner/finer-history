import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressTracker {
  static const String _progressKey = 'topic_progress';
  
  // Map of topicId -> Map of eventId -> correct count
  Map<String, Map<String, int>> _progress = {};

  /// Get progress as a percentage (0.0 to 1.0)
  /// An event counts as "correct" if it has been answered correctly at least once
  double getProgress(String topicId, int totalEvents) {
    if (totalEvents == 0) return 0.0;
    
    final correctCount = _progress[topicId]?.length ?? 0;
    return correctCount / totalEvents;
  }

  /// Get the number of times an event has been answered correctly
  int getCorrectCount(String topicId, String eventId) {
    return _progress[topicId]?[eventId] ?? 0;
  }

  /// Mark an event as correctly placed (increments count)
  Future<void> markCorrect(String topicId, String eventId) async {
    _progress.putIfAbsent(topicId, () => <String, int>{});
    _progress[topicId]![eventId] = (_progress[topicId]![eventId] ?? 0) + 1;
    await saveProgress();
  }

  /// Mark an event as incorrectly placed (decrements count, minimum 0)
  Future<void> markIncorrect(String topicId, String eventId) async {
    final topicProgress = _progress[topicId];
    if (topicProgress != null && topicProgress.containsKey(eventId)) {
      final currentCount = topicProgress[eventId] ?? 0;
      if (currentCount > 0) {
        topicProgress[eventId] = currentCount - 1;
        // Remove from map if count reaches 0 to keep data clean
        if (topicProgress[eventId] == 0) {
          topicProgress.remove(eventId);
        }
        await saveProgress();
      }
    }
  }

  /// Load progress from SharedPreferences
  Future<void> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_progressKey);
      
      if (jsonString != null) {
        final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;
        _progress = jsonData.map(
          (key, value) {
            // Handle migration from old format (Set) to new format (Map)
            if (value is List) {
              // Old format: List of event IDs (treat as count=1 for each)
              final Map<String, int> eventCounts = {};
              for (final eventId in value) {
                eventCounts[eventId as String] = 1;
              }
              return MapEntry(key, eventCounts);
            } else if (value is Map) {
              // New format: Map of eventId -> count
              return MapEntry(
                key,
                (value as Map<String, dynamic>).map(
                  (eventId, count) => MapEntry(eventId, count as int),
                ),
              );
            } else {
              return MapEntry(key, <String, int>{});
            }
          },
        );
      }
    } catch (e) {
      debugPrint('Error loading progress: $e');
      _progress = {};
    }
  }

  /// Save progress to SharedPreferences
  Future<void> saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> jsonData = _progress.map(
        (key, value) => MapEntry(
          key,
          value.map((eventId, count) => MapEntry(eventId, count)),
        ),
      );
      final String jsonString = json.encode(jsonData);
      await prefs.setString(_progressKey, jsonString);
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }
}

