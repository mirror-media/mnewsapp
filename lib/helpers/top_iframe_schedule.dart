class TopIframeSchedule {
  static const startAtKey = 'topIframeStartAt';
  static const endAtKey = 'topIframeEndAt';

  static final _timestampPattern = RegExp(
    r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:\.(\d+))?(Z|[+-](\d{2}):(\d{2}))$',
  );

  const TopIframeSchedule._({
    required this.startsAt,
    required this.endsAt,
    required this.isValid,
  });

  factory TopIframeSchedule.parse({
    required String startAt,
    required String endAt,
  }) {
    final startText = startAt.trim();
    final endText = endAt.trim();
    final start = startText.isEmpty ? null : _parseTimestamp(startText);
    final end = endText.isEmpty ? null : _parseTimestamp(endText);
    final valid =
        (startText.isEmpty || start != null) &&
        (endText.isEmpty || end != null) &&
        (start == null || end == null || end.isAfter(start));

    return TopIframeSchedule._(startsAt: start, endsAt: end, isValid: valid);
  }

  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool isValid;

  bool isActiveAt(DateTime now) {
    if (!isValid) return false;
    final instant = now.toUtc();
    return (startsAt == null || !instant.isBefore(startsAt!)) &&
        (endsAt == null || instant.isBefore(endsAt!));
  }

  DateTime? nextTransitionAfter(DateTime now) {
    if (!isValid) return null;
    final instant = now.toUtc();
    if (startsAt != null && startsAt!.isAfter(instant)) return startsAt;
    if (endsAt != null && endsAt!.isAfter(instant)) return endsAt;
    return null;
  }

  static DateTime? _parseTimestamp(String value) {
    final match = _timestampPattern.firstMatch(value);
    if (match == null) return null;

    try {
      final year = int.parse(match[1]!);
      final month = int.parse(match[2]!);
      final day = int.parse(match[3]!);
      final hour = int.parse(match[4]!);
      final minute = int.parse(match[5]!);
      final second = int.parse(match[6]!);
      final offsetHour = int.parse(match[9] ?? '0');
      final offsetMinute = int.parse(match[10] ?? '0');

      if (month < 1 ||
          month > 12 ||
          day < 1 ||
          day > 31 ||
          hour > 23 ||
          minute > 59 ||
          second > 59 ||
          offsetHour > 23 ||
          offsetMinute > 59) {
        return null;
      }

      // DateTime.parse normalizes dates such as February 30. Validate the
      // original wall-clock date before applying its explicit UTC offset.
      final date = DateTime.utc(year, month, day);
      if (date.year != year || date.month != month || date.day != day) {
        return null;
      }

      return DateTime.tryParse(value)?.toUtc();
    } catch (_) {
      return null;
    }
  }
}
