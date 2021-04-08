import 'package:tv/helpers/apiConstants.dart';
import 'package:tv/models/youtubePlaylistInfo.dart';

class ShowIntro {
  final String name;
  final String introduction;
  final String pictureUrl;

  final YoutubePlaylistInfo playList01;
  final YoutubePlaylistInfo playList02;

  ShowIntro({
    this.name,
    this.introduction,
    this.pictureUrl,

    this.playList01,
    this.playList02,
  });

  factory ShowIntro.fromJson(Map<String, dynamic> json) {
    String pictureUrl = mirrorNewsDefaultImageUrl;
    if (json['picture'] != null && 
      json['picture']['urlMobileSized'] != null) {
      pictureUrl = json['picture']['urlMobileSized'];
    }

    return ShowIntro(
      name: json['name'],
      introduction: json['introduction'],
      pictureUrl: pictureUrl,

      playList01: YoutubePlaylistInfo.parseByShow(json['playList01'], '選單 A'),
      playList02: YoutubePlaylistInfo.parseByShow(json['playList02'], '選單 B'),
    );
  }
}