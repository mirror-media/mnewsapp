import 'dart:convert';

import 'package:tv/models/programListItem.dart';

import 'customizedList.dart';

class ProgramList extends CustomizedList<ProgramListItem>{

  ProgramList();

  factory ProgramList.fromJson(List<dynamic> parsedJson) {
    ProgramList programList = ProgramList();
    List parseList = List.empty(growable: true);
    for (int i = 0; i < parsedJson.length; i++) {
      parseList.add(ProgramListItem.fromJson(parsedJson[i]));
    }
    parseList.forEach((element) {
      programList.add(element);
    });

    programList.sort((ProgramListItem a, ProgramListItem b){
      int compare = a.year.compareTo(b.year);
      if(compare != 0)
        return compare;
      compare = a.weekDay.compareTo(b.weekDay);
      if(compare != 0)
        return compare;
      compare = a.startTimeHour.compareTo(b.startTimeHour);
      if(compare != 0)
        return compare;
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