import 'dart:convert';

import 'package:tv/models/anchorperson.dart';
import 'package:tv/models/customizedList.dart';

class AnchorpersonList extends CustomizedList<Anchorperson> {
  // constructor
  AnchorpersonList();

  factory AnchorpersonList.fromJson(List<dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }

    AnchorpersonList anchorpersons = AnchorpersonList();
    List parseList = parsedJson.map((i) => Anchorperson.fromJson(i)).toList();
    parseList.forEach((element) {
      anchorpersons.add(element);
    });

    return anchorpersons;
  }

  factory AnchorpersonList.parseResponseBody(String body) {
    final jsonData = json.decode(body);

    return AnchorpersonList.fromJson(jsonData);
  }
}
