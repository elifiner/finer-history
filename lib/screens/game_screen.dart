import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_state.dart';
import '../widgets/timeline_widget.dart';
import '../widgets/event_card.dart';
import '../widgets/score_summary.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final state = gameProvider.state;

        if (state.showScoreSummary) {
          return ScoreSummary(
            roundNumber: state.currentRound,
            correctCount: state.roundCorrect,
            incorrectCount: state.roundIncorrect,
            totalPoints: state.totalPoints,
            onNextRound: () {
              gameProvider.startNextRound();
            },
            onNewGame: () {
              gameProvider.startNewGame();
            },
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context, state),
                // Unplaced event section
                if (state.unplacedEvent != null && state.draggedPosition == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: EventCard(
                      event: state.unplacedEvent!,
                      isPlaced: false,
                      isSliding: state.slidingEventId == state.unplacedEvent!.id,
                      onDragStart: () {},
                      onDragEnd: () {},
                    ),
                  ),
                // Timeline
                Expanded(
                  child: TimelineWidget(
                    placedEvents: state.placedEvents,
                    previewEvent: state.draggedPosition != null
                        ? state.unplacedEvent
                        : null,
                    previewPosition: state.draggedPosition,
                    slidingEventId: state.slidingEventId,
                    onDrop: (position) {
                      gameProvider.setDraggedPosition(position);
                    },
                    onPlace: () {
                      gameProvider.placeEvent(state.draggedPosition);
                    },
                    onPreviewDragStart: () {
                      // When dragging preview, we keep the current position
                      // The drop will update it
                    },
                    onPreviewDragEnd: () {
                      // Preview drag ended - if not dropped on target, position stays the same
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, GameState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Top row: Points, Title, Round
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Points box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${state.totalPoints} Points',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Spacer(),
              // Title
              const Text(
                'Finer History',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              // Round box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Round ${state.currentRound}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              10,
              (index) => Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _getProgressColor(state.roundProgress[index]),
                  border: Border.all(
                    color: _getProgressBorderColor(state.roundProgress[index]),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: _getProgressIcon(state.roundProgress[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(RoundProgressStatus? status) {
    switch (status) {
      case RoundProgressStatus.correct:
        return Colors.green;
      case RoundProgressStatus.incorrect:
        return Colors.red;
      case RoundProgressStatus.pending:
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getProgressBorderColor(RoundProgressStatus? status) {
    switch (status) {
      case RoundProgressStatus.correct:
        return Colors.green;
      case RoundProgressStatus.incorrect:
        return Colors.red;
      case RoundProgressStatus.pending:
      default:
        return Colors.grey[300]!;
    }
  }

  Widget? _getProgressIcon(RoundProgressStatus? status) {
    switch (status) {
      case RoundProgressStatus.correct:
        return const Text(
          '✓',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );
      case RoundProgressStatus.incorrect:
        return const Text(
          '✗',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );
      case RoundProgressStatus.pending:
      default:
        return null;
    }
  }
}

