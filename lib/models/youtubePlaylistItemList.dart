import 'package:tv/models/customizedList.dart';
import 'package:tv/models/youtubePlaylistItem.dart';

class YoutubePlaylistItemList extends CustomizedList<YoutubePlaylistItem> {
  String? nextPageToken;
  // constructor
  YoutubePlaylistItemList({this.nextPageToken});

  factory YoutubePlaylistItemList.fromJson(
      String? nextPageToken, List<dynamic> parsedJson) {
    YoutubePlaylistItemList youtubePlaylistItems =
        YoutubePlaylistItemList(nextPageToken: nextPageToken);
    List parseList =
        parsedJson.map((i) => YoutubePlaylistItem.fromJson(i)).toList();
    parseList.forEach((element) {
      youtubePlaylistItems.add(element);
    });

    return youtubePlaylistItems;
  }

  factory YoutubePlaylistItemList.fromPromotionVideosJson(
      List<dynamic> parsedJson) {
    YoutubePlaylistItemList youtubePlaylistItems = YoutubePlaylistItemList();
    List parseList = parsedJson
        .map((i) => YoutubePlaylistItem.fromPromotionVideosJson(i))
        .toList();
    parseList.forEach((element) {
      youtubePlaylistItems.add(element);
    });

    return youtubePlaylistItems;
  }
}
