import 'package:flutter_test/flutter_test.dart';
import 'package:finer_history/services/progress_tracker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProgressTracker', () {
    late ProgressTracker tracker;

    setUp(() {
      tracker = ProgressTracker();
    });

    test('getCorrectCount returns 0 for new event', () async {
      expect(tracker.getCorrectCount('topic1', 'event1'), 0);
    });

    test('markCorrect increments count', () async {
      await tracker.markCorrect('topic1', 'event1');
      expect(tracker.getCorrectCount('topic1', 'event1'), 1);

      await tracker.markCorrect('topic1', 'event1');
      expect(tracker.getCorrectCount('topic1', 'event1'), 2);

      await tracker.markCorrect('topic1', 'event1');
      expect(tracker.getCorrectCount('topic1', 'event1'), 3);
    });

    test('markIncorrect decrements count', () async {
      await tracker.markCorrect('topic1', 'event1');
      await tracker.markCorrect('topic1', 'event1');
      expect(tracker.getCorrectCount('topic1', 'event1'), 2);

      await tracker.markIncorrect('topic1', 'event1');
      expect(tracker.getCorrectCount('topic1', 'event1'), 1);

      await tracker.markIncorrect('topic1', 'event1');
      expect(tracker.getCorrectCount('topic1', 'event1'), 0);
    });

    test('markIncorrect does not go below 0', () async {
      expect(tracker.getCorrectCount('topic1', 'event1'), 0);
      await tracker.markIncorrect('topic1', 'event1');
      expect(tracker.getCorrectCount('topic1', 'event1'), 0);
    });

    test('getProgress calculates percentage correctly', () async {
      expect(tracker.getProgress('topic1', 0), 0.0);
      expect(tracker.getProgress('topic1', 10), 0.0);

      // Mark some events as correct
      await tracker.markCorrect('topic1', 'event1');
      await tracker.markCorrect('topic1', 'event2');
      await tracker.markCorrect('topic1', 'event3');

      // Progress should be 3/10 = 0.3
      expect(tracker.getProgress('topic1', 10), 0.3);
    });

    test('different topics have independent counts', () async {
      await tracker.markCorrect('topic1', 'event1');
      await tracker.markCorrect('topic1', 'event1');
      await tracker.markCorrect('topic2', 'event1');

      expect(tracker.getCorrectCount('topic1', 'event1'), 2);
      expect(tracker.getCorrectCount('topic2', 'event1'), 1);
    });

    test('multiple events in same topic tracked independently', () async {
      await tracker.markCorrect('topic1', 'event1');
      await tracker.markCorrect('topic1', 'event2');
      await tracker.markCorrect('topic1', 'event1');

      expect(tracker.getCorrectCount('topic1', 'event1'), 2);
      expect(tracker.getCorrectCount('topic1', 'event2'), 1);
    });
  });
}

