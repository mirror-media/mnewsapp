import 'dart:convert';

import 'package:tv/models/programListItem.dart';

import 'customizedList.dart';

class ProgramList extends CustomizedList<ProgramListItem> {
  ProgramList();

  factory ProgramList.fromJson(List<dynamic> parsedJson) {
    ProgramList programList = ProgramList();
    for (int i = 0; i < parsedJson.length; i++) {
      programList.add(ProgramListItem.fromJson(parsedJson[i]));
    }

    programList.sort((ProgramListItem a, ProgramListItem b) {
      int compare = a.year.compareTo(b.year);
      if (compare != 0) return compare;
      compare = a.month.compareTo(b.month);
      if (compare != 0) return compare;
      compare = a.day.compareTo(b.day);
      if (compare != 0) return compare;
      compare = a.startTimeHour.compareTo(b.startTimeHour);
      if (compare != 0) return compare;
      return a.startTimeMinute.compareTo(b.startTimeMinute);
    });

    return programList;
  }

  factory ProgramList.parseResponseBody(String body) {
    final jsonData = json.decode(body);

    return ProgramList.fromJson(jsonData);
  }

  // your custom methods
  List<Map<dynamic, dynamic>> toJsonList() {
    List<Map> programListItemMaps = List.empty(growable: true);
    for (ProgramListItem programListItem in this) {
      programListItemMaps.add(programListItem.toJson());
    }
    return programListItemMaps;
  }

  String toJsonString() {
    List<Map> programListItemMaps = List.empty(growable: true);
    for (ProgramListItem programListItem in this) {
      programListItemMaps.add(programListItem.toJson());
    }
    return json.encode(programListItemMaps);
  }
}
