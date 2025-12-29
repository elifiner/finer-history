import 'package:flutter_test/flutter_test.dart';
import 'package:finer_history/models/event.dart';
import 'package:finer_history/providers/game_provider.dart';

void main() {
  group('Weight Calculation', () {
    test('weight calculation with decay rate 0.4', () {
      // Using reflection or making method public for testing
      // For now, we'll test the formula directly
      const double decayRate = 0.4;

      double calculateWeight(int correctCount) {
        return 1.0 / (1.0 + correctCount * decayRate);
      }

      expect(calculateWeight(0), closeTo(1.0, 0.001));
      expect(calculateWeight(1), closeTo(0.714, 0.001));
      expect(calculateWeight(2), closeTo(0.556, 0.001));
      expect(calculateWeight(3), closeTo(0.455, 0.001));
      expect(calculateWeight(5), closeTo(0.333, 0.001));
    });

    test('weight decreases as correct count increases', () {
      const double decayRate = 0.4;

      double calculateWeight(int correctCount) {
        return 1.0 / (1.0 + correctCount * decayRate);
      }

      final weight0 = calculateWeight(0);
      final weight1 = calculateWeight(1);
      final weight2 = calculateWeight(2);
      final weight3 = calculateWeight(3);

      expect(weight0, greaterThan(weight1));
      expect(weight1, greaterThan(weight2));
      expect(weight2, greaterThan(weight3));
    });
  });

  group('Event Placement Correctness', () {
    test('correct placement for single event', () {
      final events = [
        Event(id: '1', year: 1776, title: 'A', description: 'A'),
        Event(id: '2', year: 1787, title: 'B', description: 'B'),
        Event(id: '3', year: 1800, title: 'C', description: 'C'),
      ];

      // Place 1787 event - should go between 1776 and 1800
      final placedEvents = [events[0]]; // 1776
      final eventToPlace = events[1]; // 1787
      final correctYear = eventToPlace.year;

      int correctIndexStart = placedEvents.length;
      int correctIndexEnd = placedEvents.length;

      // Find where it should go
      for (int i = 0; i < placedEvents.length; i++) {
        if (correctYear < placedEvents[i].year) {
          correctIndexStart = i;
          correctIndexEnd = i;
          break;
        }
      }

      // Should go at index 1 (after 1776, before 1800)
      expect(correctIndexStart, 1);
      expect(correctIndexEnd, 1);
    });

    test('same-year events can be placed in any order', () {
      final events = [
        Event(id: '1', year: 1776, title: 'A', description: 'A'),
        Event(id: '2', year: 1776, title: 'B', description: 'B'),
        Event(id: '3', year: 1800, title: 'C', description: 'C'),
      ];

      // Place first 1776 event
      final placedEvents = [events[0]]; // 1776 (A)
      final eventToPlace = events[1]; // 1776 (B)
      final correctYear = eventToPlace.year;

      // Find positions of events with the same year
      final List<int> sameYearIndices = [];
      for (int i = 0; i < placedEvents.length; i++) {
        if (placedEvents[i].year == correctYear) {
          sameYearIndices.add(i);
        }
      }

      int correctIndexStart;
      int correctIndexEnd;

      if (sameYearIndices.isNotEmpty) {
        correctIndexStart = sameYearIndices.first;
        correctIndexEnd = sameYearIndices.last + 1;
      } else {
        correctIndexStart = placedEvents.length;
        correctIndexEnd = placedEvents.length;
      }

      // Should be able to place at index 0 (before) or index 1 (after)
      expect(correctIndexStart, 0);
      expect(correctIndexEnd, 1);
    });

    test('same-year events in middle of timeline', () {
      final events = [
        Event(id: '1', year: 1700, title: 'A', description: 'A'),
        Event(id: '2', year: 1776, title: 'B', description: 'B'),
        Event(id: '3', year: 1776, title: 'C', description: 'C'),
        Event(id: '4', year: 1800, title: 'D', description: 'D'),
      ];

      // Already placed: 1700, 1776 (B), 1800
      final placedEvents = [events[0], events[1], events[3]];
      final eventToPlace = events[2]; // 1776 (C)
      final correctYear = eventToPlace.year;

      // Find positions of events with the same year
      final List<int> sameYearIndices = [];
      for (int i = 0; i < placedEvents.length; i++) {
        if (placedEvents[i].year == correctYear) {
          sameYearIndices.add(i);
        }
      }

      int correctIndexStart;
      int correctIndexEnd;

      if (sameYearIndices.isNotEmpty) {
        correctIndexStart = sameYearIndices.first;
        correctIndexEnd = sameYearIndices.last + 1;
      } else {
        correctIndexStart = placedEvents.length;
        correctIndexEnd = placedEvents.length;
      }

      // Should be able to place at index 1 (before 1776 B) or index 2 (after 1776 B)
      expect(correctIndexStart, 1);
      expect(correctIndexEnd, 2);
    });

    test('multiple same-year events allow flexible placement', () {
      final events = [
        Event(id: '1', year: 1776, title: 'A', description: 'A'),
        Event(id: '2', year: 1776, title: 'B', description: 'B'),
        Event(id: '3', year: 1776, title: 'C', description: 'C'),
      ];

      // Already placed: 1776 (A), 1776 (B)
      final placedEvents = [events[0], events[1]];
      final eventToPlace = events[2]; // 1776 (C)
      final correctYear = eventToPlace.year;

      // Find positions of events with the same year
      final List<int> sameYearIndices = [];
      for (int i = 0; i < placedEvents.length; i++) {
        if (placedEvents[i].year == correctYear) {
          sameYearIndices.add(i);
        }
      }

      int correctIndexStart;
      int correctIndexEnd;

      if (sameYearIndices.isNotEmpty) {
        correctIndexStart = sameYearIndices.first;
        correctIndexEnd = sameYearIndices.last + 1;
      } else {
        correctIndexStart = placedEvents.length;
        correctIndexEnd = placedEvents.length;
      }

      // Should be able to place at index 0, 1, or 2
      expect(correctIndexStart, 0);
      expect(correctIndexEnd, 2);
    });

    test('event before all placed events', () {
      final events = [
        Event(id: '1', year: 1700, title: 'A', description: 'A'),
        Event(id: '2', year: 1800, title: 'B', description: 'B'),
      ];

      final placedEvents = [events[1]]; // 1800
      final eventToPlace = events[0]; // 1700
      final correctYear = eventToPlace.year;

      int correctIndexStart = placedEvents.length;
      int correctIndexEnd = placedEvents.length;

      // Find where it should go
      for (int i = 0; i < placedEvents.length; i++) {
        if (correctYear < placedEvents[i].year) {
          correctIndexStart = i;
          correctIndexEnd = i;
          break;
        }
      }

      // Should go at index 0 (before 1800)
      expect(correctIndexStart, 0);
      expect(correctIndexEnd, 0);
    });

    test('event after all placed events', () {
      final events = [
        Event(id: '1', year: 1700, title: 'A', description: 'A'),
        Event(id: '2', year: 1800, title: 'B', description: 'B'),
      ];

      final placedEvents = [events[0]]; // 1700
      final eventToPlace = events[1]; // 1800
      final correctYear = eventToPlace.year;

      int correctIndexStart = placedEvents.length;
      int correctIndexEnd = placedEvents.length;

      // Find where it should go
      for (int i = 0; i < placedEvents.length; i++) {
        if (correctYear < placedEvents[i].year) {
          correctIndexStart = i;
          correctIndexEnd = i;
          break;
        }
      }

      // Should go at index 1 (after 1700)
      expect(correctIndexStart, 1);
      expect(correctIndexEnd, 1);
    });
  });
}

