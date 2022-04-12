import 'package:tv/helpers/environment.dart';
import 'package:tv/models/baseModel.dart';
import 'package:tv/models/category.dart';
import 'package:tv/models/paragrpahList.dart';
import 'package:tv/models/peopleList.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/models/tagList.dart';

class Story {
  final String? style;
  final String? name;
  final ParagraphList? brief;
  final ParagraphList? contentApiData;
  final String? publishTime;
  final String? updatedAt;

  final String? heroImage;
  final String? heroVideo;
  final String? heroCaption;

  final List<Category>? categoryList;

  final PeopleList? writers;
  final PeopleList? photographers;
  final PeopleList? cameraOperators;
  final PeopleList? designers;
  final PeopleList? engineers;
  final PeopleList? vocals;
  final String? otherbyline;

  final TagList? tags;
  final StoryListItemList? relatedStories;
  final List<String>? imageUrlList;

  Story({
    this.style,
    this.name,
    this.brief,
    this.contentApiData,
    this.publishTime,
    this.updatedAt,
    this.heroImage,
    this.heroVideo,
    this.heroCaption,
    this.categoryList,
    this.writers,
    this.photographers,
    this.cameraOperators,
    this.designers,
    this.engineers,
    this.vocals,
    this.otherbyline,
    this.tags,
    this.relatedStories,
    this.imageUrlList,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    ParagraphList brief = ParagraphList();
    if (BaseModel.hasKey(json, 'briefApiData') &&
        json["briefApiData"] != 'NaN') {
      brief = ParagraphList.parseResponseBody(json['briefApiData']);
    }

    List<String>? imageUrlList = [];

    ParagraphList contentApiData = ParagraphList();
    if (BaseModel.hasKey(json, 'contentApiData') &&
        json["contentApiData"] != 'NaN') {
      contentApiData = ParagraphList.parseResponseBody(json["contentApiData"]);
      for (var paragraph in contentApiData) {
        if (paragraph.contents != null &&
            paragraph.contents!.length > 0 &&
            paragraph.contents![0].data != '') {
          if (paragraph.type == 'image') {
            imageUrlList.add(paragraph.contents![0].data);
          } else if (paragraph.type == 'slideshow') {
            var contentList = paragraph.contents;
            for (var content in contentList!) {
              imageUrlList.add(content.data);
            }
          }
        }
      }
    }

    String photoUrl = Environment().config.mirrorNewsDefaultImageUrl;
    if (BaseModel.checkJsonKeys(json, ['heroImage', 'mobile'])) {
      photoUrl = json['heroImage']['mobile'];
      imageUrlList.insert(0, photoUrl);
    }

    String? videoUrl;
    if (BaseModel.checkJsonKeys(json, ['heroVideo', 'url'])) {
      videoUrl = json['heroVideo']['url'];
    }

    List<Category>? categoryList;
    if (BaseModel.checkJsonKeys(json, ['categories'])) {
      categoryList = List<Category>.from(
          json['categories'].map((category) => Category.fromJson(category)));
    }

    return Story(
      style: json['style'],
      name: json[BaseModel.nameKey],
      brief: brief,
      contentApiData: contentApiData,
      publishTime: json['publishTime'],
      updatedAt: json['updatedAt'],
      heroImage: photoUrl,
      heroVideo: videoUrl,
      heroCaption: json['heroCaption'],
      categoryList: categoryList,
      writers: PeopleList.fromJson(json['writers']),
      photographers: PeopleList.fromJson(json['photographers']),
      cameraOperators: PeopleList.fromJson(json['cameraOperators']),
      designers: PeopleList.fromJson(json['designers']),
      engineers: PeopleList.fromJson(json['engineers']),
      vocals: PeopleList.fromJson(json['vocals']),
      otherbyline: json['otherbyline'],
      tags: TagList.fromJson(json['tags']),
      relatedStories: StoryListItemList.fromJson(json['relatedPosts']),
      imageUrlList: imageUrlList,
    );
  }
}
