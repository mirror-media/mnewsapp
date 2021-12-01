import 'dart:convert';

import 'package:tv/models/customizedList.dart';
import 'package:tv/models/topic.dart';

class TopicList extends CustomizedList<Topic> {
  // constructor
  TopicList();

  factory TopicList.fromJson(List<dynamic> parsedJson) {
    TopicList topics = TopicList();
    List parseList = parsedJson.map((i) => Topic.fromJson(i)).toList();
    parseList.forEach((element) {
      topics.add(element);
    });

    return topics;
  }

  factory TopicList.parseResponseBody(String body) {
    final jsonData = json.decode(body);

    return TopicList.fromJson(jsonData);
  }

  // your custom methods
  List<Map<dynamic, dynamic>> toJson() {
    List<Map> topicMaps = List.empty(growable: true);

    for (Topic topic in this) {
      topicMaps.add(topic.toJson());
    }
    return topicMaps;
  }

  String toJsonString() {
    List<Map> topicMaps = List.empty(growable: true);

    for (Topic topic in this) {
      topicMaps.add(topic.toJson());
    }
    return json.encode(topicMaps);
  }
}
