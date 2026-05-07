extension NumberFormatExtension on String {
  String formatWithCommas() {
    if (isEmpty) {
      return '';
    }

    final parts = split('.');
    final wholeNumber = parts[0];

    final formattedNumber = StringBuffer();

    for (int i = wholeNumber.length - 1, count = 0; i >= 0; i--, count++) {
      if (count != 0 && count % 3 == 0) {
        formattedNumber.write(',');
      }
      formattedNumber.write(wholeNumber[i]);
    }

    final formattedWhole = formattedNumber.toString().split('').reversed.join();
    return parts.length > 1 ? '$formattedWhole.${parts[1]}' : formattedWhole;
  }

  String? electionRender() {
    if (this == ' ') return null;
    final value = int.tryParse(this);
    if (value == null) return null;
    return value.toString().formatWithCommas();
  }
}
