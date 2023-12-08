import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';

extension StringFormatExtension on String {
  String format(var arguments) => sprintf(this, arguments);

  String? convertToCustomFormat() {
    try {
      DateTime dateTime = DateFormat("MM/dd/yyyy, HH:mm:ss").parse(this);
      return DateFormat("yyyy/MM/dd").format(dateTime);
    } catch (e) {
      print("Error parsing or formatting date: $e");
      return this;
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
