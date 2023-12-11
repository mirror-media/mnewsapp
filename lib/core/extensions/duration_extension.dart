extension DurationExtension on Duration {

  String toFormattedString() {
    int seconds = inSeconds.remainder(60);
    String secondsStr = seconds.toString().padLeft(2, '0');
    if (inDays > 0) {
      return '$inDays:${inHours.remainder(24)}: ${inMinutes.remainder(60)}:${secondsStr}';
    } else if (inHours > 0) {
      return '$inHours:${inMinutes.remainder(60)}$secondsStr';
    } else if (inMinutes > 0) {
      return '$inMinutes:$secondsStr';
    } else {
      return '00:$secondsStr';
    }
  }

}
