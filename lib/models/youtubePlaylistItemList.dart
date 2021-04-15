import 'package:tv/models/customizedList.dart';
import 'package:tv/models/youtubePlaylistItem.dart';

class YoutubePlaylistItemList extends CustomizedList<YoutubePlaylistItem> {
  String nextPageToken;
  // constructor
  YoutubePlaylistItemList(this.nextPageToken);

  factory YoutubePlaylistItemList.fromJson(String nextPageToken, List<dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }

    YoutubePlaylistItemList youtubePlaylistItems = YoutubePlaylistItemList(nextPageToken);
    List parseList = parsedJson.map((i) => YoutubePlaylistItem.fromJson(i)).toList();
    parseList.forEach((element) {
      youtubePlaylistItems.add(element);
    });

    return youtubePlaylistItems;
  }
}
