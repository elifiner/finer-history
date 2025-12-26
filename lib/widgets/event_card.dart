import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final bool isPlaced;
  final bool isCorrect;
  final bool isIncorrect;
  final bool isSliding;
  final bool isPreview;
  final VoidCallback? onPlace;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;

  const EventCard({
    super.key,
    required this.event,
    this.isPlaced = false,
    this.isCorrect = false,
    this.isIncorrect = false,
    this.isSliding = false,
    this.isPreview = false,
    this.onPlace,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Card(
      elevation: isPreview ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _getBorderColor(),
          width: isPlaced ? 3 : 2,
        ),
      ),
      color: _getBackgroundColor(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            if (isPlaced && (isCorrect || isIncorrect))
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getBadgeColor(),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${event.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            if (!isPlaced && !isPreview)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.drag_indicator,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ),
            if (!isPlaced && isPreview && onPlace != null)
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag indicator for preview cards
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.drag_indicator,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    // Place button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onPlace?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Place here',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isPlaced ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  event.description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isPlaced ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (isSliding) {
      cardContent = AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        child: cardContent,
      );
    }

    // Make all unplaced cards draggable (including preview cards)
    if (!isPlaced) {
      return Draggable<Event>(
        data: event,
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Transform.scale(
            scale: 1.05,
            child: cardContent,
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: cardContent,
        ),
        onDragStarted: () {
          HapticFeedback.mediumImpact();
          onDragStart?.call();
        },
        onDragEnd: (_) {
          onDragEnd?.call();
        },
        child: cardContent,
      );
    }

    return cardContent;
  }

  Color _getBorderColor() {
    if (isPlaced) {
      if (isCorrect && !event.wasIncorrect) {
        return Colors.green;
      } else if (isIncorrect || event.wasIncorrect) {
        return Colors.red;
      }
    } else if (isPreview) {
      return Colors.green;
    }
    return const Color(0xFFD4A574);
  }

  Color _getBackgroundColor() {
    if (isPlaced) {
      return const Color(0xFF3A3A3A);
    } else if (isPreview) {
      return const Color(0xFFFFF9E6);
    }
    return const Color(0xFFF0E6D2);
  }

  Color _getBadgeColor() {
    if (isCorrect && !event.wasIncorrect) {
      return Colors.green;
    } else if (isIncorrect || event.wasIncorrect) {
      return Colors.red;
    }
    return Colors.grey;
  }
}

