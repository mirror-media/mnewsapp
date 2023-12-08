import 'package:tv/helpers/environment.dart';
import 'package:tv/models/baseModel.dart';

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
      String photoUrl = Environment().config.mirrorNewsDefaultImageUrl;
      if (BaseModel.checkJsonKeys(
          element, ['snippet', 'thumbnails', 'high', 'url'])) {
        photoUrl = element['snippet']['thumbnails']['high']['url'];
      }
      return YoutubePlaylistItem(
        youtubeVideoId: element['snippet']['resourceId']['videoId'],
        name: element['snippet']['title'],
        photoUrl: photoUrl,
        publishedAt: element['snippet']['publishedAt'],
      );
    }).toList();

    return YoutubeListInfo(
        nextPageToken: json['nextPageToken'], playList: youtubeList);
  }
}
