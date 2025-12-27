import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../models/game_state.dart';
import '../models/history_topic.dart';

class GameProvider extends ChangeNotifier {
  GameState _state = GameState(
    allEvents: [],
    roundProgress: List.filled(10, RoundProgressStatus.pending),
  );

  HistoryTopic _currentTopic = HistoryTopic.israel;

  GameState get state => _state;
  HistoryTopic get currentTopic => _currentTopic;

  Future<void> initialize() async {
    await loadTopic(_currentTopic);
  }

  Future<void> loadTopic(HistoryTopic topic) async {
    try {
      final String jsonString =
          await rootBundle.loadString(topic.assetPath);
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      
      final List<Event> events = jsonList
          .asMap()
          .entries
          .map((entry) => Event.fromJson(entry.value as Map<String, dynamic>, entry.key))
          .toList();

      _state = _state.copyWith(allEvents: events);
      startNewGame();
    } catch (e) {
      debugPrint('Error loading events: $e');
    }
  }

  Future<void> switchTopic(HistoryTopic topic) async {
    if (_currentTopic == topic) return;
    
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
      roundProgress: List.filled(10, RoundProgressStatus.pending),
      previousRoundIncorrectEvents: [],
    );
    startRound();
  }

  void startNextRound() {
    // Collect events that were incorrect in the current round
    final List<Event> incorrectEvents = [];
    for (int i = 0; i < _state.roundEvents.length; i++) {
      if (_state.roundProgress[i] == RoundProgressStatus.incorrect) {
        // Find the original event from allEvents
        final Event incorrectEvent = _state.roundEvents[i];
        final Event originalEvent = _state.allEvents.firstWhere(
          (e) => e.id == incorrectEvent.id,
          orElse: () => incorrectEvent,
        );
        incorrectEvents.add(originalEvent);
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
        final Set<String> incorrectEventIds = sourceEvents.map((e) => e.id).toSet();
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
    
    // Shuffle and select up to 10 events (or all if fewer than 10 total)
    sourceEvents.shuffle();
    final int eventsToTake = sourceEvents.length < 10 ? sourceEvents.length : 10;
    final List<Event> roundEvents = sourceEvents.take(eventsToTake).toList();

    // Pre-place the first event
    final Event firstEvent = roundEvents[0].copyWith(
      isCorrect: true,
      isIncorrect: false,
    );

    final List<RoundProgressStatus> progress = List.filled(roundEvents.length, RoundProgressStatus.pending);
    progress[0] = RoundProgressStatus.correct;

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

    // Find the index of this event in roundEvents to update progress
    final int eventIndex = _state.roundEvents
        .indexWhere((e) => e.id == eventToPlace.id);

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
      
      if (eventIndex != -1) {
        newProgress[eventIndex] = RoundProgressStatus.correct;
      }

      _state = _state.copyWith(
        roundCorrect: newRoundCorrect,
        totalPoints: newTotalPoints,
        placedEvents: newPlacedEvents,
        roundProgress: newProgress,
        clearDraggedPosition: true,
      );
    } else {
      final int newRoundIncorrect = _state.roundIncorrect + 1;
      
      final Event placedEvent = eventToPlace.copyWith(
        isCorrect: false,
        isIncorrect: true,
        wasIncorrect: true,
      );
      
      newPlacedEvents.insert(placedIndex, placedEvent);
      
      if (eventIndex != -1) {
        newProgress[eventIndex] = RoundProgressStatus.incorrect;
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
        final int wrongIndex =
            newPlacedEvents.indexWhere((e) => e.id == eventToPlace.id);
        if (wrongIndex != -1) {
          final List<Event> updatedPlacedEvents =
              List<Event>.from(newPlacedEvents);
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
    final int nextEventIndex = eventIndex + 1;
    if (nextEventIndex < _state.roundEvents.length) {
      _state = _state.copyWith(
        unplacedEvent: _state.roundEvents[nextEventIndex],
        clearDraggedPosition: true, // Clear dragged position for next card
      );
    } else {
      // No more events to place - round is complete
      _state = _state.copyWith(
        unplacedEvent: null,
        clearDraggedPosition: true,
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        _state = _state.copyWith(showScoreSummary: true);
        notifyListeners();
      });
    }

    notifyListeners();
  }
}

