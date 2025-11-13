import 'package:tv/helpers/environment.dart';
import 'package:tv/models/baseModel.dart';
import 'package:tv/models/category.dart';
import 'package:tv/models/downloadFile.dart';
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
  final List<DownloadFile>? downloadFileList;

  final String? externalBriefHtml;
  final String? externalContentHtml;

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
    this.downloadFileList,
    this.externalBriefHtml,
    this.externalContentHtml,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    // ---- brief ----
    List<Paragraph>? brief;
    final rawBrief = json['briefApiData'];
    if (rawBrief != null && rawBrief != 'NaN') {
      brief = Paragraph.parseResponseBody(rawBrief);
    }

    // ---- contentApiData + imageUrlList ----
    List<Paragraph>? contentApiData;
    List<String>? imageUrlList = [];

    final rawContent = json['contentApiData'];
    if (rawContent != null && rawContent != 'NaN') {
      contentApiData = Paragraph.parseResponseBody(rawContent);

      if (contentApiData != null) {
        for (final paragraph in contentApiData) {
          final contents = paragraph.contents;
          if (contents != null && contents.isNotEmpty) {
            if (paragraph.type == 'image') {
              imageUrlList.add(contents[0].data);
            } else if (paragraph.type == 'slideshow') {
              for (final content in contents) {
                imageUrlList.add(content.data);
              }
            }
          }
        }
      }
    }

    // ---- heroImage ----
    String? heroImage = Environment().config.mirrorNewsDefaultImageUrl;
    final heroImageJson = json['heroImage'];
    if (heroImageJson is Map && heroImageJson['mobile'] is String) {
      heroImage = heroImageJson['mobile'] as String;
      imageUrlList.insert(0, heroImage);
    }

    // ---- heroVideo ----
    String? heroVideo;
    final heroVideoJson = json['heroVideo'];
    if (heroVideoJson is Map && heroVideoJson['url'] is String) {
      heroVideo = heroVideoJson['url'] as String;
    }

    // ---- categoryList ----
    List<Category>? categoryList;
    final rawCategories = json['categories'];
    if (rawCategories is List) {
      categoryList = rawCategories
          .map((c) => Category.fromJson(c))
          .toList(growable: false);
    }

    // ---- download files ----
    List<DownloadFile>? downloadFileList;
    final rawDownload = json['download'];
    if (rawDownload is List) {
      downloadFileList = rawDownload
          .map((d) => DownloadFile.fromJson(d))
          .toList(growable: false);
    }

    // ---- writers ----
    List<People>? writers;
    final rawWriters = json['writers'];
    if (rawWriters is List) {
      writers = rawWriters
          .map((w) => People.fromJson(w))
          .toList(growable: false);
    }

    // ---- photographers ----
    List<People>? photographers;
    final rawPhotographers = json['photographers'];
    if (rawPhotographers is List) {
      photographers = rawPhotographers
          .map((p) => People.fromJson(p))
          .toList(growable: false);
    }

    // ---- cameraOperators ----
    List<People>? cameraOperators;
    final rawCameraOps = json['cameraOperators'];
    if (rawCameraOps is List) {
      cameraOperators = rawCameraOps
          .map((c) => People.fromJson(c))
          .toList(growable: false);
    }

    // ---- designers ----
    List<People>? designers;
    final rawDesigners = json['designers'];
    if (rawDesigners is List) {
      designers = rawDesigners
          .map((d) => People.fromJson(d))
          .toList(growable: false);
    }

    // ---- engineers ----
    List<People>? engineers;
    final rawEngineers = json['engineers'];
    if (rawEngineers is List) {
      engineers = rawEngineers
          .map((e) => People.fromJson(e))
          .toList(growable: false);
    }

    // ---- vocals ----
    List<People>? vocals;
    final rawVocals = json['vocals'];
    if (rawVocals is List) {
      vocals = rawVocals
          .map((v) => People.fromJson(v))
          .toList(growable: false);
    }

    // ---- tags ----
    List<Tag>? tags;
    final rawTags = json['tags'];
    if (rawTags is List) {
      tags = rawTags
          .map((t) => Tag.fromJson(t))
          .toList(growable: false);
    }

    // ---- related stories ----
    List<StoryListItem>? relatedStories;
    final rawRelated = json['relatedPosts'];
    if (rawRelated is List) {
      relatedStories = rawRelated
          .map((r) => StoryListItem.fromJson(r))
          .toList(growable: false);
    }

    // ---- external html ----
    final externalBriefHtml = json['externalBriefHtml'] as String?;
    final externalContentHtml = json['externalContentHtml'] as String?;

    return Story(
      style: json['style'] as String?,
      name: json[BaseModel.nameKey] as String?,
      brief: brief,
      contentApiData: contentApiData,
      publishTime: json['publishTime'] as String?,
      updatedAt: json['updatedAt'] as String?,
      heroImage: heroImage,
      heroVideo: heroVideo,
      heroCaption: json['heroCaption'] as String?,
      categoryList: categoryList,
      writers: writers,
      photographers: photographers,
      cameraOperators: cameraOperators,
      designers: designers,
      engineers: engineers,
      vocals: vocals,
      otherbyline: json['otherbyline'] as String?,
      tags: tags,
      relatedStories: relatedStories,
      imageUrlList: imageUrlList,
      downloadFileList: downloadFileList,
      externalBriefHtml: externalBriefHtml,
      externalContentHtml: externalContentHtml,
    );
  }

  factory Story.empty() {
    return Story();
  }
}
