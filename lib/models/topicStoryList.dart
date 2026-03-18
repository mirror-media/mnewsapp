import 'package:tv/helpers/environment.dart';
import 'package:tv/models/baseModel.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/models/video.dart';

class TopicStoryList {
  final String photoUrl;
  final String leading;
  final List<StoryListItem>? storyListItemList;
  final List<StoryListItem>? headerArticles;
  final List<Video>? headerVideoList;
  final Video? headerVideo;
  final int? allStoryCount;

  TopicStoryList({
    required this.photoUrl,
    required this.leading,
    this.storyListItemList,
    this.headerArticles,
    this.headerVideoList,
    this.headerVideo,
    this.allStoryCount,
  });

  factory TopicStoryList.fromJson(Map<String, dynamic> json,
      {bool withCount = true}) {
    String photoUrl = Environment().config.mirrorNewsDefaultImageUrl;

    final heroImage = json['heroImage'];
    if (heroImage is Map) {
      final heroImageMap = Map<String, dynamic>.from(heroImage);
      final imageApiData = heroImageMap['imageApiData'];

      if (imageApiData is Map) {
        final imageApiDataMap = Map<String, dynamic>.from(imageApiData);

        final w800 = imageApiDataMap['w800'];
        if (w800 is Map) {
          final w800Map = Map<String, dynamic>.from(w800);
          final url = w800Map['url'];
          if (url is String && url.isNotEmpty) {
            photoUrl = url;
          }
        }

        if (photoUrl == Environment().config.mirrorNewsDefaultImageUrl) {
          final directUrl = imageApiDataMap['url'];
          if (directUrl is String && directUrl.isNotEmpty) {
            photoUrl = directUrl;
          }
        }

        if (photoUrl == Environment().config.mirrorNewsDefaultImageUrl) {
          final w480 = imageApiDataMap['w480'];
          if (w480 is Map) {
            final w480Map = Map<String, dynamic>.from(w480);
            final url = w480Map['url'];
            if (url is String && url.isNotEmpty) {
              photoUrl = url;
            }
          }
        }
      }
    }

    print('===== TopicStoryList photoUrl =====');
    print(photoUrl);

    List<StoryListItem>? storyListItemList;
    int? allStoryCount;
    if (json['post'] != null && json['post'].length > 0) {
      storyListItemList = List<StoryListItem>.from(
          json['post'].map((post) => StoryListItem.fromJson(post)));
      if (withCount) {
        allStoryCount = json['postCount'];
      }
    }

    String leading = 'image';
    if (BaseModel.checkJsonKeys(json, ['leading'])) {
      leading = json['leading'];
    }

    Video? heroVideo;
    List<Video> headerVideoList = [];
    List<StoryListItem>? headerArticles;
    switch (leading) {
      case 'video':
        if (BaseModel.checkJsonKeys(json, ['heroVideo', 'url'])) {
          heroVideo = Video.fromJson(json['heroVideo']);
        } else {
          leading = 'image';
        }
        break;
      case 'multivideo':
        if (json['multivideo'] != null && json['multivideo'].isNotEmpty) {
          for (var video in json['multivideo']) {
            headerVideoList.add(Video.fromJson(video));
          }
        } else {
          leading = 'image';
        }
        break;
      case 'slideshow':
        if (json['slideshow'] != null && json['slideshow'].isNotEmpty) {
          headerArticles = List<StoryListItem>.from(
              json['slideshow'].map((post) => StoryListItem.fromJson(post)));
        } else {
          leading = 'image';
        }
        break;
    }

    return TopicStoryList(
      photoUrl: photoUrl,
      storyListItemList: storyListItemList,
      leading: leading,
      headerVideo: heroVideo,
      headerArticles: headerArticles,
      headerVideoList: headerVideoList,
      allStoryCount: allStoryCount,
    );
  }
}
