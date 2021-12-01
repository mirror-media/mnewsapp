import 'dart:convert';

import 'package:tv/models/customizedList.dart';
import 'package:tv/models/paragraph.dart';

class ParagraphList extends CustomizedList<Paragraph> {
  // constructor
  ParagraphList();

  factory ParagraphList.fromJson(List<dynamic> parsedJson) {
    ParagraphList paragraphs = ParagraphList();
    List parseList = parsedJson.map((i) => Paragraph.fromJson(i)).toList();
    parseList.forEach((element) {
      paragraphs.add(element);
    });

    return paragraphs;
  }

  factory ParagraphList.parseResponseBody(String body,
      {bool isNotApiData: false}) {
    try {
      final jsonData = json.decode(body);
      if (isNotApiData) {
        return ParagraphList.fromJson(jsonData['apiData']);
      }
      if (jsonData == "" || jsonData == null) {
        return ParagraphList();
      }

      return ParagraphList.fromJson(jsonData);
    } catch (e) {
      return ParagraphList();
    }
  }
}
