import 'package:tv/helpers/environment.dart';
import 'package:tv/models/baseModel.dart';
import 'package:tv/models/storyListItemList.dart';

class TopicStoryList {
  final String? photoUrl;
  StoryListItemList? storyListItemList;

  TopicStoryList({
    this.photoUrl,
    this.storyListItemList,
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

    return TopicStoryList(
      photoUrl: photoUrl,
      storyListItemList: storyListItemList,
    );
  }
}
