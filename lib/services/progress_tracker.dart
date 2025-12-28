import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressTracker {
  static const String _progressKey = 'topic_progress';
  
  // Map of topicId -> Set of correct event IDs
  Map<String, Set<String>> _progress = {};

  /// Get progress as a percentage (0.0 to 1.0)
  double getProgress(String topicId, int totalEvents) {
    if (totalEvents == 0) return 0.0;
    
    final correctCount = _progress[topicId]?.length ?? 0;
    return correctCount / totalEvents;
  }

  /// Mark an event as correctly placed
  Future<void> markCorrect(String topicId, String eventId) async {
    _progress.putIfAbsent(topicId, () => <String>{});
    _progress[topicId]!.add(eventId);
    await saveProgress();
  }

  /// Mark an event as incorrectly placed (removes from correct set if present)
  Future<void> markIncorrect(String topicId, String eventId) async {
    _progress[topicId]?.remove(eventId);
    await saveProgress();
  }

  /// Load progress from SharedPreferences
  Future<void> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_progressKey);
      
      if (jsonString != null) {
        final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;
        _progress = jsonData.map(
          (key, value) => MapEntry(
            key,
            (value as List<dynamic>).map((e) => e as String).toSet(),
          ),
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
        (key, value) => MapEntry(key, value.toList()),
      );
      final String jsonString = json.encode(jsonData);
      await prefs.setString(_progressKey, jsonString);
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }
}

