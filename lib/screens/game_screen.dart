import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_state.dart';
import '../widgets/timeline_widget.dart';
import '../widgets/event_card.dart';
import '../widgets/score_summary.dart';
import '../widgets/topic_selection_dialog.dart';

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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          drawer: _buildDrawer(context, gameProvider),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // Header
                    _buildHeader(context, state, gameProvider),
                    // Unplaced event section
                    if (state.unplacedEvent != null &&
                        state.draggedPosition == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: EventCard(
                          event: state.unplacedEvent!,
                          isPlaced: false,
                          isSliding:
                              state.slidingEventId == state.unplacedEvent!.id,
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    GameState state,
    GameProvider gameProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Top row: Hamburger, Points, Title, Round
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hamburger menu icon
              Builder(
                builder: (builderContext) => IconButton(
                  icon: Icon(Icons.menu, color: colorScheme.onSurface),
                  onPressed: () {
                    Scaffold.of(builderContext).openDrawer();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 8),
              // Points box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${state.totalPoints} Points',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const Spacer(),
              // Title (current topic name)
              Text(
                gameProvider.currentTopic?.displayName ?? 'History',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              // Round box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Round ${state.currentRound}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress boxes - centered using Stack for reliable centering
          Stack(
            children: [
              // Invisible row to match top row structure for alignment
              Row(
                children: [
                  Builder(
                    builder: (builderContext) => IconButton(
                      icon: Icon(Icons.menu, color: Colors.transparent),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Opacity(
                    opacity: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${state.totalPoints} Points',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Invisible title for measurement
                  Text(
                    gameProvider.currentTopic?.displayName ?? 'History',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.transparent,
                    ),
                  ),
                  const Spacer(),
                  Opacity(
                    opacity: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Round ${state.currentRound}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Progress boxes centered
              Positioned.fill(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      state.roundProgress.length,
                      (index) => Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: _getProgressColor(
                            state.roundProgress[index],
                            colorScheme,
                          ),
                          border: Border.all(
                            color: _getProgressBorderColor(
                              state.roundProgress[index],
                              colorScheme,
                            ),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child:
                            _getProgressIcon(
                              state.roundProgress[index],
                              colorScheme,
                            ) ??
                            const SizedBox(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(
    RoundProgressStatus? status,
    ColorScheme colorScheme,
  ) {
    switch (status) {
      case RoundProgressStatus.correct:
        return colorScheme.primary;
      case RoundProgressStatus.incorrect:
        return colorScheme.error;
      case RoundProgressStatus.pending:
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }

  Color _getProgressBorderColor(
    RoundProgressStatus? status,
    ColorScheme colorScheme,
  ) {
    switch (status) {
      case RoundProgressStatus.correct:
        return colorScheme.primary;
      case RoundProgressStatus.incorrect:
        return colorScheme.error;
      case RoundProgressStatus.pending:
      default:
        return colorScheme.outline;
    }
  }

  Widget? _getProgressIcon(
    RoundProgressStatus? status,
    ColorScheme colorScheme,
  ) {
    switch (status) {
      case RoundProgressStatus.correct:
        return Icon(Icons.check, color: colorScheme.onPrimary, size: 14);
      case RoundProgressStatus.incorrect:
        return Icon(Icons.close, color: colorScheme.onError, size: 14);
      case RoundProgressStatus.pending:
      default:
        return null;
    }
  }

  Widget _buildDrawer(BuildContext context, GameProvider gameProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Finer History',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a History Topic',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings, color: colorScheme.onSurfaceVariant),
            title: Text('More Topics', style: theme.textTheme.bodyLarge),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const TopicSelectionDialog(),
              );
            },
          ),
          const Divider(),
          ...gameProvider.availableTopics.map((topic) {
            final isSelected = gameProvider.currentTopic?.id == topic.id;
            return ListTile(
              leading: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? colorScheme.primary
                    : theme.listTileTheme.iconColor ??
                          colorScheme.onSurfaceVariant,
              ),
              title: Text(
                topic.displayName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.primary
                      : theme.listTileTheme.textColor ?? colorScheme.onSurface,
                ),
              ),
              selected: isSelected,
              selectedTileColor: colorScheme.primaryContainer.withValues(
                alpha: 0.3,
              ),
              onTap: () {
                Navigator.pop(context);
                gameProvider.switchTopic(topic);
              },
            );
          }),
        ],
      ),
    );
  }
}
