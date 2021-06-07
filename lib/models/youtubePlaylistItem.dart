import 'package:tv/helpers/apiConstants.dart';
import 'package:tv/models/baseModel.dart';
import 'package:youtube_plyr_iframe/youtube_plyr_iframe.dart';

class YoutubePlaylistItem {
  final String youtubeVideoId;
  final String name;
  final String photoUrl;
  final String? publishedAt;

  YoutubePlaylistItem({
    required this.youtubeVideoId,
    required this.name,
    required this.photoUrl,
    required this.publishedAt,
  });

  factory YoutubePlaylistItem.fromJson(Map<String, dynamic> json) {
    String photoUrl = mirrorNewsDefaultImageUrl;
    if (BaseModel.checkJsonKeys(json, ['snippet', 'thumbnails', 'high', 'url'])) {
      photoUrl = json['snippet']['thumbnails']['high']['url'];
    }

    return YoutubePlaylistItem(
      youtubeVideoId: json['snippet']['resourceId']['videoId'],
      name: json['snippet']['title'],
      photoUrl: photoUrl,
      publishedAt: json['snippet']['publishedAt'],
    );
  }

  factory YoutubePlaylistItem.fromPromotionVideosJson(Map<String, dynamic> json) {
    String? ytId = YoutubePlayerController.convertUrlToId(json['ytUrl']);

    String photoUrl = mirrorNewsDefaultImageUrl;
    if(ytId != null) {
      photoUrl = YoutubePlayerController.getThumbnail(videoId: ytId);
    }

    return YoutubePlaylistItem(
      youtubeVideoId: ytId ?? '',
      name: '',
      photoUrl: photoUrl,
      publishedAt: null,
    );
  }
} 