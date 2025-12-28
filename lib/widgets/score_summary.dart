import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ScoreSummary extends StatefulWidget {
  final int roundNumber;
  final int correctCount;
  final int incorrectCount;
  final int totalPoints;
  final VoidCallback onNextRound;
  final VoidCallback onNewGame;
  final ConfettiController? confettiController;

  const ScoreSummary({
    super.key,
    required this.roundNumber,
    required this.correctCount,
    required this.incorrectCount,
    required this.totalPoints,
    required this.onNextRound,
    required this.onNewGame,
    this.confettiController,
  });

  @override
  State<ScoreSummary> createState() => _ScoreSummaryState();
}

class _ScoreSummaryState extends State<ScoreSummary> {
  bool _hasPlayedConfetti = false;

  bool get isPerfectRound => widget.incorrectCount == 0 && widget.correctCount > 0;

  @override
  void initState() {
    super.initState();
    // Trigger confetti if perfect round
    if (isPerfectRound && widget.confettiController != null && !_hasPlayedConfetti) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.confettiController?.play();
        setState(() {
          _hasPlayedConfetti = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Perfect round celebration message
                          if (isPerfectRound) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                'Perfect Round! 🎉',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          Text(
                            'Round ${widget.roundNumber} Complete!',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          _buildScoreItem(
                            context,
                            'Correct:',
                            widget.correctCount.toString(),
                            colorScheme.primary,
                          ),
                          const SizedBox(height: 10),
                          _buildScoreItem(
                            context,
                            'Incorrect:',
                            widget.incorrectCount.toString(),
                            colorScheme.error,
                          ),
                          const SizedBox(height: 20),
                          _buildScoreItem(
                            context,
                            'Total Points:',
                            widget.totalPoints.toString(),
                            colorScheme.secondary,
                            isTotal: true,
                          ),
                          const SizedBox(height: 30),
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    widget.onNextRound();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Next Round',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    widget.onNewGame();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.surfaceContainerHighest,
                                    foregroundColor: colorScheme.onSurface,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'New Game',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Confetti widget - explode from center
        if (widget.confettiController != null && isPerfectRound)
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: widget.confettiController!,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 10,
              minBlastForce: 5,
              emissionFrequency: 0.01,
              numberOfParticles: 80,
              gravity: 0.3,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildScoreItem(
    BuildContext context,
    String label,
    String value,
    Color color, {
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: isTotal ? 20 : 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: isTotal ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
