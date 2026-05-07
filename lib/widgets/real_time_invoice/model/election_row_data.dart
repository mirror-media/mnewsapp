import '../core/extension/string_extension.dart';

class ElectionRowData {
  String? key;
  List<String> valueList;

  ElectionRowData({this.key, required this.valueList});

  factory ElectionRowData.fromJson(Map<String, dynamic> json) {
    List<String> valueList = [];
    for (var valueItem in json['value']) {
      for (var key in valueItem.keys) {
        valueList.add(valueItem[key].toString());
      }
    }

    return ElectionRowData(
      valueList: valueList,
      key: json['key'],
    );
  }

  List<String> get renderText {
    if (key == '當選') return valueList;
    if (key == '得票率') return valueList.map((value) => '$value%').toList();
    return valueList.map((value) => value.formatWithCommas()).toList();
  }
}
