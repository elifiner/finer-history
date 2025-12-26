import 'event.dart';

enum RoundProgressStatus { correct, incorrect, pending }

class GameState {
  final List<Event> allEvents;
  final int currentRound;
  final int totalPoints;
  final int roundCorrect;
  final int roundIncorrect;
  final List<Event> roundEvents;
  final List<Event> placedEvents;
  final Event? unplacedEvent;
  final bool showScoreSummary;
  final int? draggedPosition;
  final String? slidingEventId;
  final List<RoundProgressStatus> roundProgress;

  GameState({
    required this.allEvents,
    this.currentRound = 1,
    this.totalPoints = 0,
    this.roundCorrect = 0,
    this.roundIncorrect = 0,
    this.roundEvents = const [],
    this.placedEvents = const [],
    this.unplacedEvent,
    this.showScoreSummary = false,
    this.draggedPosition,
    this.slidingEventId,
    this.roundProgress = const [],
  });

  GameState copyWith({
    List<Event>? allEvents,
    int? currentRound,
    int? totalPoints,
    int? roundCorrect,
    int? roundIncorrect,
    List<Event>? roundEvents,
    List<Event>? placedEvents,
    Event? unplacedEvent,
    bool? showScoreSummary,
    int? draggedPosition,
    bool clearDraggedPosition = false, // Flag to explicitly clear
    String? slidingEventId,
    bool clearSlidingEventId = false, // Flag to explicitly clear
    List<RoundProgressStatus>? roundProgress,
  }) {
    return GameState(
      allEvents: allEvents ?? this.allEvents,
      currentRound: currentRound ?? this.currentRound,
      totalPoints: totalPoints ?? this.totalPoints,
      roundCorrect: roundCorrect ?? this.roundCorrect,
      roundIncorrect: roundIncorrect ?? this.roundIncorrect,
      roundEvents: roundEvents ?? this.roundEvents,
      placedEvents: placedEvents ?? this.placedEvents,
      unplacedEvent: unplacedEvent ?? this.unplacedEvent,
      showScoreSummary: showScoreSummary ?? this.showScoreSummary,
      draggedPosition: clearDraggedPosition 
          ? null 
          : (draggedPosition ?? this.draggedPosition),
      slidingEventId: clearSlidingEventId 
          ? null 
          : (slidingEventId ?? this.slidingEventId),
      roundProgress: roundProgress ?? this.roundProgress,
    );
  }
}

