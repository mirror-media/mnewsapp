enum PlaybackStatus {
  normalRate,
  onePointFiveRate,
  doubleRate,
}

extension PlaybackStatusExtension on PlaybackStatus {
  String get displayValue {
    switch (this) {
      case PlaybackStatus.normalRate:
        return 'X1';
      case PlaybackStatus.onePointFiveRate:
        return 'X1.5';
      case PlaybackStatus.doubleRate:
        return 'X2';
    }
  }
}
