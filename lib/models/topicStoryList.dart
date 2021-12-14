import 'package:tv/helpers/environment.dart';
import 'package:tv/models/baseModel.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/models/video.dart';

class TopicStoryList {
  final String photoUrl;
  final String leading;
  final StoryListItemList? storyListItemList;
  final StoryListItemList? headerArticles;
  final List<Video>? headerVideoList;
  final Video? headerVideo;

  TopicStoryList({
    required this.photoUrl,
    required this.leading,
    this.storyListItemList,
    this.headerArticles,
    this.headerVideoList,
    this.headerVideo,
  });

  factory TopicStoryList.fromJson(Map<String, dynamic> json) {
    String photoUrl = Environment().config.mirrorNewsDefaultImageUrl;
    if (BaseModel.checkJsonKeys(json, ['heroImage', 'urlMobileSized'])) {
      photoUrl = json['heroImage']['urlMobileSized'];
    }

    StoryListItemList? storyListItemList;
    if (json['post'] != null && json['post'].length > 0) {
      storyListItemList = StoryListItemList.fromJson(json['post']);
    }

    String leading = 'image';
    if (BaseModel.checkJsonKeys(json, ['leading'])) {
      leading = json['leading'];
    }

    Video? heroVideo;
    if (BaseModel.checkJsonKeys(json, ['heroVideo'])) {
      heroVideo = Video.fromJson(json['heroVideo']);
    }

    return TopicStoryList(
      photoUrl: photoUrl,
      storyListItemList: storyListItemList,
      leading: leading,
      headerVideo: heroVideo,
    );
  }
}
