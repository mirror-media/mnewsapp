import 'package:flutter_test/flutter_test.dart';
import 'package:tv/helpers/top_iframe_schedule.dart';

void main() {
  group('TopIframeSchedule', () {
    test('empty bounds preserve the existing unrestricted behavior', () {
      final schedule = TopIframeSchedule.parse(startAt: ' \n', endAt: '\t ');
      final now = DateTime.utc(2026, 11, 28);

      expect(schedule.isValid, isTrue);
      expect(schedule.startsAt, isNull);
      expect(schedule.endsAt, isNull);
      expect(schedule.isActiveAt(now), isTrue);
      expect(schedule.nextTransitionAfter(now), isNull);
    });

    test('includes the start and excludes the end', () {
      final schedule = TopIframeSchedule.parse(
        startAt: '2026-11-28T08:00:00+08:00',
        endAt: '2026-11-28T18:00:00+08:00',
      );
      final start = DateTime.utc(2026, 11, 28);
      final end = DateTime.utc(2026, 11, 28, 10);

      expect(schedule.isValid, isTrue);
      expect(schedule.startsAt, start);
      expect(schedule.endsAt, end);
      expect(
        schedule.isActiveAt(start.subtract(const Duration(microseconds: 1))),
        isFalse,
      );
      expect(schedule.isActiveAt(start), isTrue);
      expect(
        schedule.isActiveAt(end.subtract(const Duration(microseconds: 1))),
        isTrue,
      );
      expect(schedule.isActiveAt(end), isFalse);
      expect(schedule.isActiveAt(end.add(const Duration(hours: 1))), isFalse);

      expect(
        schedule.nextTransitionAfter(start.subtract(const Duration(hours: 1))),
        start,
      );
      expect(schedule.nextTransitionAfter(start), end);
      expect(
        schedule.nextTransitionAfter(start.add(const Duration(hours: 1))),
        end,
      );
      expect(schedule.nextTransitionAfter(end), isNull);
    });

    test('supports a start without an end', () {
      final schedule = TopIframeSchedule.parse(
        startAt: '2026-11-28T00:00:00Z',
        endAt: '',
      );
      final start = DateTime.utc(2026, 11, 28);
      final before = start.subtract(const Duration(seconds: 1));

      expect(schedule.isValid, isTrue);
      expect(schedule.endsAt, isNull);
      expect(schedule.isActiveAt(before), isFalse);
      expect(schedule.nextTransitionAfter(before), start);
      expect(schedule.isActiveAt(start), isTrue);
      expect(schedule.nextTransitionAfter(start), isNull);
      expect(schedule.isActiveAt(DateTime.utc(2030)), isTrue);
    });

    test('supports an end without a start', () {
      final schedule = TopIframeSchedule.parse(
        startAt: '',
        endAt: '2026-11-28T10:00:00Z',
      );
      final end = DateTime.utc(2026, 11, 28, 10);
      final before = end.subtract(const Duration(seconds: 1));

      expect(schedule.isValid, isTrue);
      expect(schedule.startsAt, isNull);
      expect(schedule.isActiveAt(before), isTrue);
      expect(schedule.nextTransitionAfter(before), end);
      expect(schedule.isActiveAt(end), isFalse);
      expect(schedule.nextTransitionAfter(end), isNull);
      expect(schedule.isActiveAt(DateTime.utc(2030)), isFalse);
    });

    test(
      'compares offsets as UTC instants, including across calendar dates',
      () {
        final schedule = TopIframeSchedule.parse(
          startAt: ' 2026-11-28T00:00:00+08:00 ',
          endAt: '2026-11-27T17:00:00-01:00',
        );

        expect(schedule.isValid, isTrue);
        expect(schedule.startsAt, DateTime.utc(2026, 11, 27, 16));
        expect(schedule.endsAt, DateTime.utc(2026, 11, 27, 18));
        expect(schedule.startsAt!.isUtc, isTrue);
        expect(schedule.endsAt!.isUtc, isTrue);
        expect(schedule.isActiveAt(DateTime.utc(2026, 11, 27, 17)), isTrue);
        expect(
          schedule.isActiveAt(DateTime.utc(2026, 11, 27, 17).toLocal()),
          isTrue,
        );
        expect(
          schedule.nextTransitionAfter(
            DateTime.utc(2026, 11, 27, 17).toLocal(),
          ),
          DateTime.utc(2026, 11, 27, 18),
        );
      },
    );

    test('accepts fractional seconds and a valid leap day', () {
      final schedule = TopIframeSchedule.parse(
        startAt: '2028-02-29T08:00:00.123456+08:00',
        endAt: '2028-02-29T00:00:00.124Z',
      );

      expect(schedule.isValid, isTrue);
      expect(schedule.startsAt, DateTime.utc(2028, 2, 29, 0, 0, 0, 123, 456));
      expect(schedule.endsAt, DateTime.utc(2028, 2, 29, 0, 0, 0, 124));
      expect(schedule.isActiveAt(schedule.startsAt!), isTrue);
      expect(schedule.isActiveAt(schedule.endsAt!), isFalse);
    });

    test('invalid bounds never activate or schedule a transition', () {
      final now = DateTime.utc(2026, 11, 28);
      const invalidBounds = [
        'not a timestamp',
        '2026-11-28',
        '2026-11-28T08:00:00',
        '2026-11-28T08:00Z',
        '2026-11-28 08:00:00Z',
        '2026/11/28T08:00:00Z',
        '2026-11-28T08:00:00+0800',
        '2026-11-28T08:00:00+08',
        '2026-11-28T08:00:00. Z',
        '2026-11-28T08:00:00,5Z',
        '2026-02-29T08:00:00Z',
        '2028-02-30T08:00:00Z',
        '1900-02-29T08:00:00Z',
        '2026-04-31T08:00:00Z',
        '2026-00-28T08:00:00Z',
        '2026-13-28T08:00:00Z',
        '2026-11-00T08:00:00Z',
        '2026-11-32T08:00:00Z',
        '2026-11-28T24:00:00Z',
        '2026-11-28T08:60:00Z',
        '2026-11-28T08:00:60Z',
        '2026-11-28T08:00:00+24:00',
        '2026-11-28T08:00:00-08:60',
      ];

      for (final value in invalidBounds) {
        for (final schedule in [
          TopIframeSchedule.parse(startAt: value, endAt: ''),
          TopIframeSchedule.parse(startAt: '', endAt: value),
        ]) {
          expect(schedule.isValid, isFalse, reason: value);
          expect(schedule.isActiveAt(now), isFalse, reason: value);
          expect(schedule.nextTransitionAfter(now), isNull, reason: value);
        }
      }
    });

    test('rejects end times at or before the start after UTC conversion', () {
      for (final end in [
        '2026-11-28T00:00:00Z',
        '2026-11-28T09:00:00+09:00',
        '2026-11-27T23:59:59Z',
      ]) {
        final schedule = TopIframeSchedule.parse(
          startAt: '2026-11-28T08:00:00+08:00',
          endAt: end,
        );

        expect(schedule.isValid, isFalse, reason: end);
        expect(schedule.isActiveAt(DateTime.utc(2026, 11, 28)), isFalse);
        expect(
          schedule.nextTransitionAfter(DateTime.utc(2026, 11, 27)),
          isNull,
        );
      }
    });
  });
}
