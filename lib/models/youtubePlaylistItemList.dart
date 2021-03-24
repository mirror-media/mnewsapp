import 'dart:convert';

import 'package:tv/models/customizedList.dart';
import 'package:tv/models/youtubePlaylistItem.dart';

class YoutubePlaylistItemList extends CustomizedList<YoutubePlaylistItem> {
  // constructor
  YoutubePlaylistItemList();

  factory YoutubePlaylistItemList.fromJson(List<dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }

    YoutubePlaylistItemList youtubePlaylistItems = YoutubePlaylistItemList();
    List parseList = parsedJson.map((i) => YoutubePlaylistItem.fromJson(i)).toList();
    parseList.forEach((element) {
      youtubePlaylistItems.add(element);
    });

    return youtubePlaylistItems;
  }

  factory YoutubePlaylistItemList.parseResponseBody(String body) {
    final jsonData = json.decode(body);

    return YoutubePlaylistItemList.fromJson(jsonData);
  }
}
