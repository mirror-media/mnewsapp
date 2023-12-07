import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';

extension StringFormatExtension on String {
  String format(var arguments) => sprintf(this, arguments);

  String? convertToCustomFormat() {
    try {
      DateTime dateTime = DateTime.parse(this);

      final customFormat = DateFormat('yyyy/MMM/dd');

      return customFormat.format(dateTime);
    } catch (e) {
      return null;
    }
  }

  String? convertToDisplayText() {
    try {
      DateTime dateTime = DateTime.parse(this);
      final customFormat = DateFormat('yyyy年MM月dd日');
      return customFormat.format(dateTime);
    } catch (e) {
      return null;
    }
  }
}
