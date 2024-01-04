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

  StoryListItem({
    this.id,
    this.name,
    this.slug,
    this.style,
    required this.photoUrl,
    this.categoryList,
    this.isSales,
  });

  factory StoryListItem.fromJsonSales(Map<String, dynamic> json) {
    String photoUrl = Environment().config.mirrorNewsDefaultImageUrl;
    if (BaseModel.checkJsonKeys(
        json, ['adPost', 'heroImage', 'urlMobileSized'])) {
      photoUrl = json['adPost']['heroImage']['urlMobileSized'];
    }

    List<Category>? allPostsCategory;
    if (json['adPost']['categories'] != null) {
      allPostsCategory = List<Category>.from(json['adPost']['categories']
          .map((category) => Category.fromJson(category)));
    }

    return StoryListItem(
        id: json['adPost'][BaseModel.idKey],
        name: json['adPost'][BaseModel.nameKey],
        slug: json['adPost'][BaseModel.slugKey],
        style: json['adPost']['style'],
        photoUrl: photoUrl,
        isSales: true,
        categoryList: allPostsCategory);
  }

  factory StoryListItem.fromJson(Map<String, dynamic> json) {
    if (BaseModel.hasKey(json, '_source')) {
      json = json['_source'];
    }

    String photoUrl = Environment().config.mirrorNewsDefaultImageUrl;
    if (BaseModel.checkJsonKeys(json, ['heroImage', 'urlMobileSized'])) {
      photoUrl = json['heroImage']['urlMobileSized'];
    } else if (BaseModel.checkJsonKeys(
        json, ['heroVideo', 'coverPhoto', 'urlMobileSized'])) {
      photoUrl = json['heroVideo']['coverPhoto']['urlMobileSized'];
    }

    List<Category>? allPostsCategory;
    if (json['categories'] != null) {
      allPostsCategory = List<Category>.from(
          json['categories'].map((category) => Category.fromJson(category)));
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
        categoryList: allPostsCategory);
  }

  Map<String, dynamic> toJson() => {
        BaseModel.idKey: id,
        BaseModel.nameKey: name,
        BaseModel.slugKey: slug,
        'style': style,
        'photoUrl': photoUrl,
      };

  @override
  int get hashCode => slug.hashCode;

  @override
  bool operator ==(covariant StoryListItem other) {
    // compare this to other
    return this.slug == other.slug;
  }
}
