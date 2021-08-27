import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class CustomPicker extends DateTimePickerModel{
  CustomPicker({
    required DateTime currentTime,
    LocaleType? locale,
    DateTime? maxTime}) : super(locale: locale, maxTime: maxTime) {
    this.currentTime = currentTime;
    this.minTime = currentTime;
  }

  @override
  List<int> layoutProportions() {
    return [1,0,0];
  }

  @override
  String leftDivider() {
    return "";
  }

  @override
  String rightDivider() {
    return "";
  }
}