import 'youtubePlaylistItem.dart';

class YoutubeListInfo {
  String? nextPageToken;
  List<YoutubePlaylistItem>? playList;

  YoutubeListInfo({
    this.nextPageToken,
    this.playList,
  });

  factory YoutubeListInfo.fromJson(Map<String, dynamic> json) {
    final itemJson = json['items'] as List<dynamic>;
    final youtubeList = itemJson.map((element) {
      return YoutubePlaylistItem.fromJson(element);
    }).toList();

    return YoutubeListInfo(
        nextPageToken: json['nextPageToken'], playList: youtubeList);
  }
}
