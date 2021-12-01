import 'package:tv/helpers/environment.dart';
import 'package:tv/models/baseModel.dart';
import 'package:tv/models/categoryList.dart';

class StoryListItem {
  String? id;
  String name;
  String slug;
  String? style;
  String photoUrl;
  CategoryList? categoryList;

  StoryListItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.style,
    required this.photoUrl,
    this.categoryList,
  });

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

    CategoryList? allPostsCategory;
    if (json['categories'] != null) {
      allPostsCategory = CategoryList.fromJson(json['categories']);
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
  int get hashCode => this.hashCode;

  @override
  bool operator ==(covariant StoryListItem other) {
    // compare this to other
    return this.slug == other.slug;
  }
}
