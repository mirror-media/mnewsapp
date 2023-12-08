import 'package:tv/helpers/environment.dart';
import 'package:tv/models/baseModel.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

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
    String photoUrl = Environment().config.mirrorNewsDefaultImageUrl;
    if (BaseModel.checkJsonKeys(
        json, ['snippet', 'thumbnails', 'high', 'url'])) {
      photoUrl = json['snippet']['thumbnails']['high']['url'];
    }

    return YoutubePlaylistItem(
      youtubeVideoId: json['snippet']['resourceId']['videoId'],
      name: json['snippet']['title'],
      photoUrl: photoUrl,
      publishedAt: json['snippet']['publishedAt'],
    );
  }

  factory YoutubePlaylistItem.fromPromotionVideosJson(
      Map<String, dynamic> json) {
    String? ytId = VideoId.parseVideoId(json['ytUrl']);

    String photoUrl = Environment().config.mirrorNewsDefaultImageUrl;
    if (ytId != null) {
      photoUrl = ThumbnailSet(ytId).standardResUrl;
    }

    return YoutubePlaylistItem(
      youtubeVideoId: ytId ?? '',
      name: '',
      photoUrl: photoUrl,
      publishedAt: null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YoutubePlaylistItem && other.name == name;

  @override
  int get hashCode => name.hashCode;
}
