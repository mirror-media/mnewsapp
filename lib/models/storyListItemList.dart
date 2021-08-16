import 'dart:convert';

import 'package:tv/models/customizedList.dart';
import 'package:tv/models/storyListItem.dart';

class StoryListItemList extends CustomizedList<StoryListItem> {
  int allStoryCount = 0;
  // constructor
  StoryListItemList();

  factory StoryListItemList.fromJson(List<dynamic> parsedJson) {
    StoryListItemList storyListItemList = StoryListItemList();
    List parseList = parsedJson.map((i) => StoryListItem.fromJson(i)).toList();
    parseList.forEach((element) {
      storyListItemList.add(element);
    });

    return storyListItemList;
  }

  factory StoryListItemList.fromJsonGCP(List<dynamic> parsedJson) {
    StoryListItemList storyListItemList = StoryListItemList();
    List parseList = parsedJson.map((i) => StoryListItem.fromJson(i)).toList();
    parseList.forEach((element) {
      storyListItemList.add(element);
    });

    return storyListItemList;
  }

  factory StoryListItemList.parseResponseBody(String body) {
    final jsonData = json.decode(body);

    return StoryListItemList.fromJson(jsonData);
  }

  // your custom methods
  List<Map<dynamic, dynamic>> toJsonList() {
    List<Map> storyListItemMaps = List.empty(growable: true);
    for (StoryListItem storyListItem in this) {
      storyListItemMaps.add(storyListItem.toJson());
    }
    return storyListItemMaps;
  }
  
  String toJsonString() {
    List<Map> storyListItemMaps = List.empty(growable: true);
    for (StoryListItem storyListItem in this) {
      storyListItemMaps.add(storyListItem.toJson());
    }
    return json.encode(storyListItemMaps);
  }
}
