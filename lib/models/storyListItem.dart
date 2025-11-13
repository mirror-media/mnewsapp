import 'package:tv/helpers/environment.dart';
import 'package:tv/models/baseModel.dart';
import 'package:tv/models/category.dart';

class StoryListItem {
  String? id;
  String? name;
  String? slug;
  String? style;
  String photoUrl;
  List<Category>? categoryList;
  bool? isSales = false;
  String? displayCategory;

  // ✅ 新增欄位：鏡報（External）專用
  String? source;
  String? subtitle;
  String? heroCaption;
  String? brief;
  String? content;
  String? briefOriginal;
  String? contentOriginal;
  String? publishTime;
  String? updatedAt;
  String? partnerName;

  StoryListItem({
    this.id,
    this.name,
    this.slug,
    this.style,
    required this.photoUrl,
    this.categoryList,
    this.isSales,
    this.displayCategory,
    this.source,
    this.subtitle,
    this.heroCaption,
    this.brief,
    this.content,
    this.briefOriginal,
    this.contentOriginal,
    this.publishTime,
    this.updatedAt,
    this.partnerName,
  });

  /// ✅ 原本 Sales 類型
  factory StoryListItem.fromJsonSales(Map<String, dynamic> json) {
    String photoUrl = Environment().config.mirrorNewsDefaultImageUrl;
    if (BaseModel.checkJsonKeys(
        json, ['adPost', 'heroImage', 'urlMobileSized'])) {
      photoUrl = json['adPost']['heroImage']['urlMobileSized'];
    }

    String? displayCategory;
    List<Category>? allPostsCategory;
    if (json['adPost']['categories'] != null) {
      allPostsCategory = List<Category>.from(json['adPost']['categories']
          .map((category) => Category.fromJson(category)));
      if (allPostsCategory.isNotEmpty) {
        displayCategory = allPostsCategory.first.name;
      }
      for (var postsCategory in allPostsCategory) {
        if (postsCategory.slug == 'ombuds') {
          displayCategory = "公評人";
          break;
        }
      }
    }

    return StoryListItem(
      id: json['adPost'][BaseModel.idKey],
      name: json['adPost'][BaseModel.nameKey],
      slug: json['adPost'][BaseModel.slugKey],
      style: json['adPost']['style'],
      photoUrl: photoUrl,
      isSales: true,
      categoryList: allPostsCategory,
      displayCategory: displayCategory,
    );
  }

  /// ✅ 通用解析器 — 自動辨識 allPosts / allExternals
  factory StoryListItem.fromJson(Map<String, dynamic> json) {
    // GraphQL _source 包裝處理
    if (BaseModel.hasKey(json, '_source')) {
      json = json['_source'];
    }

    // ==========================
    // 判斷是否為 External 鏡報資料
    // ==========================
    if (json.containsKey('partner') || json.containsKey('brief_original')) {
      return StoryListItem(
        id: json[BaseModel.idKey]?.toString(),
        name: json[BaseModel.nameKey],
        slug: json[BaseModel.slugKey],
        subtitle: json['subtitle'],
        photoUrl: json['thumbnail'] ??
            Environment().config.mirrorNewsDefaultImageUrl,
        heroCaption: json['heroCaption'],
        brief: json['brief'],
        content: json['content'],
        briefOriginal: json['brief_original'],
        contentOriginal: json['content_original'],
        publishTime: json['publishTime'],
        updatedAt: json['updatedAt'],
        source: json['source'],
        partnerName: json['partner']?['name'],
        categoryList: json['categories'] != null
            ? List<Category>.from(
            json['categories'].map((c) => Category.fromJson(c)))
            : [],
        displayCategory: (json['categories'] != null &&
            (json['categories'] as List).isNotEmpty)
            ? json['categories'][0]['name']
            : "鏡報",
      );
    }

    // ==========================
    // 否則走舊 allPosts 流程
    // ==========================
    String photoUrl = Environment().config.mirrorNewsDefaultImageUrl;
    if (BaseModel.checkJsonKeys(json, ['heroImage', 'urlMobileSized'])) {
      photoUrl = json['heroImage']['urlMobileSized'];
    } else if (BaseModel.checkJsonKeys(
        json, ['heroVideo', 'coverPhoto', 'urlMobileSized'])) {
      photoUrl = json['heroVideo']['coverPhoto']['urlMobileSized'];
    }

    String? displayCategory;
    List<Category>? allPostsCategory;
    if (json['categories'] != null) {
      allPostsCategory = List<Category>.from(
          json['categories'].map((category) => Category.fromJson(category)));
      if (allPostsCategory.isNotEmpty) {
        displayCategory = allPostsCategory.first.name;
      }
      for (var postsCategory in allPostsCategory) {
        if (postsCategory.slug == 'ombuds') {
          displayCategory = "公評人";
          break;
        }
      }
    }

    String? style;
    if (BaseModel.checkJsonKeys(json, ['style'])) {
      style = json['style'];
    }

    return StoryListItem(
      id: json[BaseModel.idKey],
      name: json[BaseModel.nameKey],
      slug: json[BaseModel.slugKey],
      style: style,
      photoUrl: photoUrl,
      isSales: false,
      categoryList: allPostsCategory,
      displayCategory: displayCategory,
    );
  }

  Map<String, dynamic> toJson() => {
    BaseModel.idKey: id,
    BaseModel.nameKey: name,
    BaseModel.slugKey: slug,
    'style': style,
    'photoUrl': photoUrl,
    'source': source,
    'briefOriginal': briefOriginal,
    'contentOriginal': contentOriginal,
  };

  @override
  int get hashCode => slug.hashCode;

  @override
  bool operator ==(covariant StoryListItem other) => slug == other.slug;
}