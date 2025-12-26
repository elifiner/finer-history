import 'package:flutter/material.dart';

class ScoreSummary extends StatelessWidget {
  final int roundNumber;
  final int correctCount;
  final int incorrectCount;
  final int totalPoints;
  final VoidCallback onNextRound;
  final VoidCallback onNewGame;

  const ScoreSummary({
    super.key,
    required this.roundNumber,
    required this.correctCount,
    required this.incorrectCount,
    required this.totalPoints,
    required this.onNextRound,
    required this.onNewGame,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
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
                Text(
                  'Round $roundNumber Complete!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                _buildScoreItem(
                  context,
                  'Correct:',
                  correctCount.toString(),
                  Colors.green,
                ),
                const SizedBox(height: 10),
                _buildScoreItem(
                  context,
                  'Incorrect:',
                  incorrectCount.toString(),
                  Colors.red,
                ),
                const SizedBox(height: 20),
                _buildScoreItem(
                  context,
                  'Total Points:',
                  totalPoints.toString(),
                  Colors.blue,
                  isTotal: true,
                ),
                const SizedBox(height: 30),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          onNextRound();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Next Round',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          onNewGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'New Game',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildScoreItem(
    BuildContext context,
    String label,
    String value,
    Color color, {
    bool isTotal = false,
  }) {
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
            style: TextStyle(
              fontSize: isTotal ? 20 : 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
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

