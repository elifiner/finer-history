import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import '../models/event.dart';
import '../models/game_state.dart';
import '../models/history_topic.dart';
import '../services/progress_tracker.dart';

class GameProvider extends ChangeNotifier {
  GameState _state = GameState(
    allEvents: [],
    roundProgress: List.filled(10, RoundProgressStatus.pending),
  );

  HistoryTopic? _currentTopic;
  List<HistoryTopic> _availableTopics = [];
  List<HistoryTopic> _allTopics = [];
  Set<String> _enabledTopicIds = {};
  final ProgressTracker _progressTracker = ProgressTracker();
  final Map<String, int> _topicEventCounts = {};
  ConfettiController? _confettiController;

  static const String _enabledTopicsKey = 'enabled_topic_ids';
  static const Set<String> _defaultEnabledTopicIds = {
    'us',
    'evolution',
    'computing',
    'rome',
    'greece',
  };

  GameState get state => _state;
  HistoryTopic? get currentTopic => _currentTopic;
  List<HistoryTopic> get availableTopics => _availableTopics;
  List<HistoryTopic> get allTopics => _allTopics;
  ConfettiController? get confettiController => _confettiController;

  bool isTopicEnabled(String topicId) => _enabledTopicIds.contains(topicId);

  double getTopicProgress(String topicId) {
    final totalEvents = _topicEventCounts[topicId] ?? 0;
    if (totalEvents == 0) return 0.0;
    return _progressTracker.getProgress(topicId, totalEvents);
  }

  bool canDisableTopic(String topicId) {
    // Can only disable if there's more than one enabled topic
    return _enabledTopicIds.length > 1;
  }

  Future<void> initialize() async {
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    await _progressTracker.loadProgress();
    await discoverTopics();
    await loadEnabledTopics();
    _updateAvailableTopics();
    if (_availableTopics.isNotEmpty) {
      _currentTopic = _availableTopics.first;
      await loadTopic(_currentTopic!);
    }
  }

  @override
  void dispose() {
    _confettiController?.dispose();
    super.dispose();
  }

  Future<void> discoverTopics() async {
    try {
      // List of known topic files - in a real app, you might scan the assets directory
      final List<String> topicFiles = [
        'assets/data/us.json',
        'assets/data/rome.json',
        'assets/data/greece.json',
        'assets/data/israel.json',
        'assets/data/palestine.json',
        'assets/data/evolution.json',
        'assets/data/computing.json',
      ];

      _allTopics = [];

      for (final assetPath in topicFiles) {
        try {
          final String jsonString = await rootBundle.loadString(assetPath);
          final Map<String, dynamic> jsonData =
              json.decode(jsonString) as Map<String, dynamic>;

          final String category = jsonData['category'] as String;
          final String id = assetPath.split('/').last.replaceAll('.json', '');
          final List<dynamic> events = jsonData['events'] as List<dynamic>;

          // Cache event count for this topic
          _topicEventCounts[id] = events.length;

          _allTopics.add(
            HistoryTopic(id: id, displayName: category, assetPath: assetPath),
          );
        } catch (e) {
          debugPrint('Error loading topic from $assetPath: $e');
        }
      }
    } catch (e) {
      debugPrint('Error discovering topics: $e');
    }
  }

  Future<void> loadEnabledTopics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? savedIds = prefs.getStringList(_enabledTopicsKey);

      if (savedIds != null && savedIds.isNotEmpty) {
        _enabledTopicIds = savedIds.toSet();
      } else {
        // First launch - use defaults
        _enabledTopicIds = Set<String>.from(_defaultEnabledTopicIds);
        await saveEnabledTopics();
      }
    } catch (e) {
      debugPrint('Error loading enabled topics: $e');
      // Fallback to defaults on error
      _enabledTopicIds = Set<String>.from(_defaultEnabledTopicIds);
    }
  }

  Future<void> saveEnabledTopics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_enabledTopicsKey, _enabledTopicIds.toList());
    } catch (e) {
      debugPrint('Error saving enabled topics: $e');
    }
  }

  void _updateAvailableTopics() {
    _availableTopics = _allTopics
        .where((topic) => _enabledTopicIds.contains(topic.id))
        .toList();
  }

  Future<void> toggleTopicEnabled(String topicId) async {
    if (_enabledTopicIds.contains(topicId)) {
      // Disabling a topic - prevent if it's the last enabled topic
      if (_enabledTopicIds.length <= 1) {
        debugPrint('Cannot disable the last enabled topic');
        return;
      }
      _enabledTopicIds.remove(topicId);

      // If this was the current topic, switch to first available topic
      if (_currentTopic?.id == topicId) {
        _updateAvailableTopics();
        if (_availableTopics.isNotEmpty) {
          _currentTopic = _availableTopics.first;
          await loadTopic(_currentTopic!);
        } else {
          _currentTopic = null;
        }
      } else {
        _updateAvailableTopics();
      }
    } else {
      // Enabling a topic
      _enabledTopicIds.add(topicId);
      _updateAvailableTopics();
    }

    await saveEnabledTopics();
    notifyListeners();
  }

  Future<void> loadTopic(HistoryTopic topic) async {
    try {
      final String jsonString = await rootBundle.loadString(topic.assetPath);
      final Map<String, dynamic> jsonData =
          json.decode(jsonString) as Map<String, dynamic>;
      final List<dynamic> jsonList = jsonData['events'] as List<dynamic>;

      final List<Event> events = jsonList
          .asMap()
          .entries
          .map(
            (entry) =>
                Event.fromJson(entry.value as Map<String, dynamic>, entry.key),
          )
          .toList();

      // Ensure event count is cached
      _topicEventCounts[topic.id] = events.length;

      _state = _state.copyWith(allEvents: events);
      startNewGame();
    } catch (e) {
      debugPrint('Error loading events: $e');
    }
  }

  Future<void> switchTopic(HistoryTopic topic) async {
    if (_currentTopic?.id == topic.id) return;

    _currentTopic = topic;
    await loadTopic(topic);
    notifyListeners();
  }

  void startNewGame() {
    _state = GameState(
      allEvents: _state.allEvents,
      currentRound: 1,
      totalPoints: 0,
      roundCorrect: 0,
      roundIncorrect: 0,
      roundProgress: const [],
      previousRoundIncorrectEvents: [],
    );
    startRound();
  }

  void startNextRound() {
    // Collect events that were incorrect in the current round
    // roundProgress tracks the 10 placeable events (excluding the anchor)
    // roundProgress[i] corresponds to roundEvents[i+1] (since roundEvents[0] is the anchor)
    final List<Event> incorrectEvents = [];
    for (int i = 0; i < _state.roundProgress.length; i++) {
      if (_state.roundProgress[i] == RoundProgressStatus.incorrect) {
        // Find the corresponding event in roundEvents (index i+1 because 0 is anchor)
        final int roundEventIndex = i + 1;
        if (roundEventIndex < _state.roundEvents.length) {
          final Event incorrectEvent = _state.roundEvents[roundEventIndex];
          final Event originalEvent = _state.allEvents.firstWhere(
            (e) => e.id == incorrectEvent.id,
            orElse: () => incorrectEvent,
          );
          incorrectEvents.add(originalEvent);
        }
      }
    }

    _state = _state.copyWith(
      currentRound: _state.currentRound + 1,
      roundCorrect: 0,
      roundIncorrect: 0,
      previousRoundIncorrectEvents: incorrectEvents,
    );
    startRound();
  }

  void startRound() {
    // Use incorrect events from previous round if available, otherwise use all events
    List<Event> sourceEvents;
    if (_state.previousRoundIncorrectEvents.isNotEmpty) {
      // Start with incorrect events from previous round
      sourceEvents = List<Event>.from(_state.previousRoundIncorrectEvents);

      // If we have fewer than 10 incorrect events, supplement with additional events from allEvents
      if (sourceEvents.length < 10) {
        // Get events that aren't already in the incorrect events list
        final Set<String> incorrectEventIds = sourceEvents
            .map((e) => e.id)
            .toSet();
        final List<Event> additionalEvents = _state.allEvents
            .where((e) => !incorrectEventIds.contains(e.id))
            .toList();

        // Shuffle and take enough to reach 10 (or all available if less than 10 total)
        additionalEvents.shuffle();
        final int needed = 10 - sourceEvents.length;
        final int available = additionalEvents.length;
        final int toAdd = needed < available ? needed : available;
        sourceEvents.addAll(additionalEvents.take(toAdd));
      }
    } else {
      sourceEvents = _state.allEvents;
    }

    // Shuffle and select 11 events (10 to place + 1 pre-placed anchor)
    // If we have fewer than 11 total, use what we have
    sourceEvents.shuffle();
    final int targetCount = 11;
    final int eventsToTake = sourceEvents.length < targetCount
        ? sourceEvents.length
        : targetCount;
    final List<Event> roundEvents = sourceEvents.take(eventsToTake).toList();

    // Pre-place the first event (this is the anchor, not counted in progress)
    final Event firstEvent = roundEvents[0].copyWith(
      isCorrect: true,
      isIncorrect: false,
    );

    // roundProgress tracks the 10 placeable cards (excluding the anchor)
    // Initialize with pending status for all placeable cards
    final int placeableCount = roundEvents.length > 1
        ? roundEvents.length - 1
        : 0;
    final List<RoundProgressStatus> progress = List.filled(
      placeableCount,
      RoundProgressStatus.pending,
    );

    _state = _state.copyWith(
      roundEvents: roundEvents,
      placedEvents: [firstEvent],
      unplacedEvent: roundEvents.length > 1 ? roundEvents[1] : null,
      showScoreSummary: false,
      draggedPosition: null,
      slidingEventId: null,
      roundProgress: progress,
    );
    notifyListeners();
  }

  void setDraggedPosition(int? position) {
    _state = _state.copyWith(draggedPosition: position);
    notifyListeners();
  }

  void placeEvent(int? position) {
    if (_state.unplacedEvent == null) return;

    final Event eventToPlace = _state.unplacedEvent!;
    final int correctYear = eventToPlace.year;

    // Determine correct position based on year
    int correctIndex = _state.placedEvents.length;
    for (int i = 0; i < _state.placedEvents.length; i++) {
      if (correctYear < _state.placedEvents[i].year) {
        correctIndex = i;
        break;
      }
    }

    // Convert position to index
    int placedIndex = position ?? _state.placedEvents.length;

    // Check if placement is correct
    final bool isCorrect = placedIndex == correctIndex;

    // Find the index of this event in the placeable events (excluding the anchor)
    // roundEvents[0] is the anchor, so placeable events start at index 1
    // eventIndex will be 0-9 for the 10 placeable events
    final int roundEventIndex = _state.roundEvents.indexWhere(
      (e) => e.id == eventToPlace.id,
    );
    final int eventIndex = roundEventIndex > 0 ? roundEventIndex - 1 : -1;

    final List<Event> newPlacedEvents = List<Event>.from(_state.placedEvents);
    final List<RoundProgressStatus> newProgress =
        List<RoundProgressStatus>.from(_state.roundProgress);

    if (isCorrect) {
      final int newRoundCorrect = _state.roundCorrect + 1;
      final int newTotalPoints = _state.totalPoints + 1;

      final Event placedEvent = eventToPlace.copyWith(
        isCorrect: true,
        isIncorrect: false,
      );

      newPlacedEvents.insert(correctIndex, placedEvent);

      // Update progress for this placed card (eventIndex is the index in placeable events)
      if (eventIndex != -1 && eventIndex < newProgress.length) {
        newProgress[eventIndex] = RoundProgressStatus.correct;
      }

      // Update progress tracking
      String? celebrationMessage;
      if (_currentTopic != null) {
        _progressTracker.markCorrect(_currentTopic!.id, eventToPlace.id);

        // Check if topic reached 100% completion
        final progress = _progressTracker.getProgress(
          _currentTopic!.id,
          _topicEventCounts[_currentTopic!.id] ?? 0,
        );
        if (progress >= 1.0) {
          celebrationMessage = 'Topic Complete! 🎉';
          _confettiController?.play();

          // Auto-dismiss celebration message after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (_state.celebrationMessage == celebrationMessage) {
              _state = _state.copyWith(clearCelebrationMessage: true);
              notifyListeners();
            }
          });
        }
      }

      _state = _state.copyWith(
        roundCorrect: newRoundCorrect,
        totalPoints: newTotalPoints,
        placedEvents: newPlacedEvents,
        roundProgress: newProgress,
        clearDraggedPosition: true,
        celebrationMessage: celebrationMessage,
      );
    } else {
      final int newRoundIncorrect = _state.roundIncorrect + 1;

      final Event placedEvent = eventToPlace.copyWith(
        isCorrect: false,
        isIncorrect: true,
        wasIncorrect: true,
      );

      newPlacedEvents.insert(placedIndex, placedEvent);

      // Update progress for this placed card (eventIndex is the index in placeable events)
      if (eventIndex != -1 && eventIndex < newProgress.length) {
        newProgress[eventIndex] = RoundProgressStatus.incorrect;
      }

      // Update progress tracking - remove from correct set if present
      if (_currentTopic != null) {
        _progressTracker.markIncorrect(_currentTopic!.id, eventToPlace.id);
      }

      _state = _state.copyWith(
        roundIncorrect: newRoundIncorrect,
        placedEvents: newPlacedEvents,
        roundProgress: newProgress,
        clearDraggedPosition: true,
        slidingEventId: eventToPlace.id,
      );

      // Move to correct position after a brief delay
      Future.delayed(const Duration(milliseconds: 100), () {
        final int wrongIndex = newPlacedEvents.indexWhere(
          (e) => e.id == eventToPlace.id,
        );
        if (wrongIndex != -1) {
          final List<Event> updatedPlacedEvents = List<Event>.from(
            newPlacedEvents,
          );
          updatedPlacedEvents.removeAt(wrongIndex);

          // Find correct position
          int newCorrectIndex = updatedPlacedEvents.length;
          for (int i = 0; i < updatedPlacedEvents.length; i++) {
            if (correctYear < updatedPlacedEvents[i].year) {
              newCorrectIndex = i;
              break;
            }
          }

          final Event correctedEvent = placedEvent.copyWith(
            isIncorrect: false,
            isCorrect: true,
          );
          updatedPlacedEvents.insert(newCorrectIndex, correctedEvent);

          _state = _state.copyWith(placedEvents: updatedPlacedEvents);

          // After animation completes
          Future.delayed(const Duration(milliseconds: 300), () {
            _state = _state.copyWith(clearSlidingEventId: true);
            notifyListeners();
          });
        }
        notifyListeners();
      });
    }

    // Find next event to place
    // eventIndex is the index in placeable events (0-9), roundEventIndex is the index in roundEvents (1-10)
    // The next placeable event would be at roundEventIndex + 1
    final int nextRoundEventIndex = roundEventIndex + 1;
    if (nextRoundEventIndex < _state.roundEvents.length) {
      _state = _state.copyWith(
        unplacedEvent: _state.roundEvents[nextRoundEventIndex],
        clearDraggedPosition: true, // Clear dragged position for next card
      );
    } else {
      // No more events to place - round is complete
      _state = _state.copyWith(unplacedEvent: null, clearDraggedPosition: true);

      Future.delayed(const Duration(milliseconds: 1500), () {
        _state = _state.copyWith(showScoreSummary: true);
        notifyListeners();
      });
    }

    notifyListeners();
  }
}
