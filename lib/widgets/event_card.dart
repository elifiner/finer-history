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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Widget cardContent = Card(
      elevation: isPreview ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _getBorderColor(colorScheme),
          width: isPlaced ? 3 : 2,
        ),
      ),
      color: _getBackgroundColor(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            // Year badge (for placed cards) or Place button (for preview cards)
            // Both positioned at the same location
            if (isPlaced && (isCorrect || isIncorrect))
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getBadgeColor(colorScheme),
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
            if (!isPlaced && isPreview && onPlace != null)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
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
                    color: colorScheme.primary,
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
              ),
            // Content with padding on the right to avoid overlap with button/year
            Padding(
              padding: const EdgeInsets.only(right: 90),
              child: Column(
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

  Color _getBorderColor(ColorScheme colorScheme) {
    if (isPlaced) {
      if (isCorrect && !event.wasIncorrect) {
        return colorScheme.primary;
      } else if (isIncorrect || event.wasIncorrect) {
        return colorScheme.error;
      }
    } else if (isPreview) {
      return colorScheme.primary;
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

  Color _getBadgeColor(ColorScheme colorScheme) {
    if (isCorrect && !event.wasIncorrect) {
      return colorScheme.primary;
    } else if (isIncorrect || event.wasIncorrect) {
      return colorScheme.error;
    }
    return colorScheme.surfaceContainerHighest;
  }
}

