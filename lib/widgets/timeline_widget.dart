import 'package:flutter/material.dart';
import '../models/event.dart';
import 'event_card.dart';

class TimelineWidget extends StatefulWidget {
  final List<Event> placedEvents;
  final Event? previewEvent;
  final int? previewPosition;
  final String? slidingEventId;
  final Function(int?) onDrop;
  final VoidCallback? onPlace;
  final VoidCallback? onPreviewDragStart;
  final VoidCallback? onPreviewDragEnd;

  const TimelineWidget({
    super.key,
    required this.placedEvents,
    this.previewEvent,
    this.previewPosition,
    this.slidingEventId,
    required this.onDrop,
    this.onPlace,
    this.onPreviewDragStart,
    this.onPreviewDragEnd,
  });

  @override
  State<TimelineWidget> createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget> {
  int? _dragOverIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Vertical timeline line - centered relative to container width
            Positioned(
              left: constraints.maxWidth / 2 - 1.5,
              top: 28, // Start below BEFORE pill
              bottom: 28, // End above AFTER pill
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF8B6914),
                      const Color(0xFFD4A574),
                      const Color(0xFF8B6914),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Scrollable timeline content including BEFORE and AFTER
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              itemCount: _buildTimelineItems(colorScheme).length,
              itemBuilder: (context, index) {
                return _buildTimelineItems(colorScheme)[index];
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildTimelineItems(ColorScheme colorScheme) {
    final List<Widget> items = [];

    // BEFORE marker at the top
    items.add(_buildBeforeMarker());

    // Show preview at top if no events placed yet
    if (widget.previewEvent != null && 
        widget.placedEvents.isEmpty && 
        widget.previewPosition == null) {
      items.add(_buildPreviewItem());
      items.add(_buildDropZone(null, colorScheme));
      items.add(_buildAfterMarker());
      return items;
    }

    // Build timeline with placed events and preview
    for (int i = 0; i <= widget.placedEvents.length; i++) {
      // Show preview before this position (if position is a number)
      if (widget.previewEvent != null && 
          widget.previewPosition != null && 
          widget.previewPosition == i) {
        items.add(_buildPreviewItem());
      }

      // Drop zone before this position
      items.add(_buildDropZone(i, colorScheme));

      // Placed event at this position
      if (i < widget.placedEvents.length) {
        items.add(_buildPlacedEvent(i));
      }
    }

    // Show preview at bottom if previewPosition is null and there are placed events
    if (widget.previewEvent != null && 
        widget.placedEvents.isNotEmpty && 
        widget.previewPosition == null) {
      items.add(_buildPreviewItem());
      items.add(_buildDropZone(null, colorScheme));
    }

    // AFTER marker at the bottom
    items.add(_buildAfterMarker());

    return items;
  }

  Widget _buildBeforeMarker() {
    return Center(
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'BEFORE',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B6914),
          ),
        ),
      ),
    );
  }

  Widget _buildAfterMarker() {
    return Center(
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'AFTER',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B6914),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewItem() {
    if (widget.previewEvent == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: EventCard(
        event: widget.previewEvent!,
        isPlaced: false,
        isPreview: true,
        onPlace: widget.onPlace,
        onDragStart: widget.onPreviewDragStart,
        onDragEnd: widget.onPreviewDragEnd,
      ),
    );
  }

  Widget _buildPlacedEvent(int index) {
    if (index < 0 || index >= widget.placedEvents.length) {
      return const SizedBox.shrink();
    }

    final event = widget.placedEvents[index];
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: EventCard(
        event: event,
        isPlaced: true,
        isCorrect: event.isCorrect,
        isIncorrect: event.isIncorrect,
        isSliding: widget.slidingEventId == event.id,
      ),
    );
  }

  Widget _buildDropZone(int? index, ColorScheme colorScheme) {
    final bool isDragOver = _dragOverIndex == index;
    
    return DragTarget<Event>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        widget.onDrop(index);
        setState(() {
          _dragOverIndex = null;
        });
      },
      onMove: (details) {
        setState(() {
          _dragOverIndex = index;
        });
      },
      onLeave: (data) {
        setState(() {
          _dragOverIndex = null;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          height: isDragOver ? 80 : 20,
          margin: isDragOver ? const EdgeInsets.symmetric(vertical: 12) : EdgeInsets.zero,
          decoration: BoxDecoration(
            border: isDragOver
                ? Border.all(color: colorScheme.primary, width: 2, style: BorderStyle.solid)
                : null,
            borderRadius: BorderRadius.circular(6),
            color: isDragOver ? colorScheme.primary.withValues(alpha: 0.08) : Colors.transparent,
          ),
        );
      },
    );
  }
}
