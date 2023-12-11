import 'package:tv/helpers/environment.dart';
import 'package:tv/models/baseModel.dart';
import 'package:tv/models/youtubePlaylistInfo.dart';

class ElectionInfo {
  final String name;
  final String introduction;
  final String pictureUrl;

  final YoutubePlaylistInfo? playList01;
  final YoutubePlaylistInfo? playList02;

  ElectionInfo({
    required this.name,
    required this.introduction,
    required this.pictureUrl,
    this.playList01,
    this.playList02,
  });

  factory ElectionInfo.fromJson(Map<String, dynamic> json) {
    String pictureUrl = Environment().config.mirrorNewsDefaultImageUrl;
    if (BaseModel.checkJsonKeys(json, ['picture', 'urlMobileSized'])) {
      pictureUrl = json['picture']['urlMobileSized'];
    }

    return ElectionInfo(
      name: json['name'],
      introduction: json['introduction'] ?? '',
      pictureUrl: pictureUrl,
      playList01: YoutubePlaylistInfo.parseByShow(json['playList01'], '選單 A'),
      playList02: YoutubePlaylistInfo.parseByShow(json['playList02'], '選單 B'),
    );
  }
}
