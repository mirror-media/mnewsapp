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
    final snippet = json['snippet'] ?? {};
    final thumbnails = snippet['thumbnails'] ?? {};

    String photoUrl = _extractThumbnail(thumbnails) ??
        Environment().config.mirrorNewsDefaultImageUrl;

    return YoutubePlaylistItem(
      youtubeVideoId: snippet['resourceId']?['videoId'] ?? '',
      name: snippet['title'] ?? '',
      photoUrl: photoUrl,
      publishedAt: snippet['publishedAt'],
    );
  }

  /// 🔥 關鍵：多尺寸 fallback
  static String? _extractThumbnail(Map<String, dynamic> thumbnails) {
    const priority = ['maxres', 'standard', 'high', 'medium', 'default'];

    for (final key in priority) {
      final item = thumbnails[key];
      if (item != null && item['url'] != null) {
        return item['url'];
      }
    }
    return null;
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