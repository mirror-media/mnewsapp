import 'package:tv/helpers/environment.dart';
import 'package:tv/models/baseModel.dart';
import 'package:tv/models/category.dart';
import 'package:tv/models/paragraph.dart';
import 'package:tv/models/people.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/models/tag.dart';

class Story {
  final String? style;
  final String? name;
  final List<Paragraph>? brief;
  final List<Paragraph>? contentApiData;
  final String? publishTime;
  final String? updatedAt;

  final String? heroImage;
  final String? heroVideo;
  final String? heroCaption;

  final List<Category>? categoryList;

  final List<People>? writers;
  final List<People>? photographers;
  final List<People>? cameraOperators;
  final List<People>? designers;
  final List<People>? engineers;
  final List<People>? vocals;
  final String? otherbyline;

  final List<Tag>? tags;
  final List<StoryListItem>? relatedStories;
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
    List<Paragraph>? brief;
    if (BaseModel.hasKey(json, 'briefApiData') &&
        json["briefApiData"] != 'NaN') {
      brief = Paragraph.parseResponseBody(json['briefApiData']);
    }

    List<String>? imageUrlList = [];

    List<Paragraph>? contentApiData;
    if (BaseModel.hasKey(json, 'contentApiData') &&
        json["contentApiData"] != 'NaN') {
      contentApiData = Paragraph.parseResponseBody(json["contentApiData"]);
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
      writers: List<People>.from(
          json['writers'].map((writer) => People.fromJson(writer))),
      photographers: List<People>.from(json['photographers']
          .map((photographer) => People.fromJson(photographer))),
      cameraOperators: List<People>.from(json['cameraOperators']
          .map((cameraOperator) => People.fromJson(cameraOperator))),
      designers: List<People>.from(
          json['designers'].map((designer) => People.fromJson(designer))),
      engineers: List<People>.from(
          json['engineers'].map((engineer) => People.fromJson(engineer))),
      vocals: List<People>.from(
          json['vocals'].map((vocal) => People.fromJson(vocal))),
      otherbyline: json['otherbyline'],
      tags: List<Tag>.from(json['tags'].map((tag) => Tag.fromJson(tag))),
      relatedStories: List<StoryListItem>.from(
          json['relatedPosts'].map((post) => StoryListItem.fromJson(post))),
      imageUrlList: imageUrlList,
    );
  }
}
