import 'package:tv/baseConfig.dart';
import 'package:tv/models/baseModel.dart';

class StoryListItem {
  String? id;
  String name;
  String slug;
  String? style;
  String photoUrl;
  List<AllPostsCategory>? category;
  String publishTime;

  StoryListItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.style,
    required this.photoUrl,
    this.category,
    required this.publishTime,
  });

  factory StoryListItem.fromJson(Map<String, dynamic> json) {
    if(BaseModel.hasKey(json, '_source')) {
      json = json['_source'];
    }

    String photoUrl = baseConfig!.mirrorNewsDefaultImageUrl;
    if (BaseModel.checkJsonKeys(json, ['heroImage', 'urlMobileSized'])) {
      photoUrl = json['heroImage']['urlMobileSized'];
    } else if (BaseModel.checkJsonKeys(json, ['heroVideo', 'coverPhoto', 'urlMobileSized'])) {
      photoUrl = json['heroVideo']['coverPhoto']['urlMobileSized'];
    }

    return StoryListItem(
      id: json[BaseModel.idKey],
      name: json[BaseModel.nameKey],
      slug: json[BaseModel.slugKey],
      style: json['style'],
      photoUrl: photoUrl,
      publishTime: json['publishTime']
    );
  }

  factory StoryListItem.fromJsonGCP(Map<String, dynamic> json) {
    if(BaseModel.hasKey(json, '_source')) {
      json = json['_source'];
    }

    String photoUrl = baseConfig!.mirrorNewsDefaultImageUrl;
    if (BaseModel.checkJsonKeys(json, ['heroImage', 'urlMobileSized'])) {
      photoUrl = json['heroImage']['urlMobileSized'];
    } else if (BaseModel.checkJsonKeys(json, ['heroVideo', 'coverPhoto', 'urlMobileSized'])) {
      photoUrl = json['heroVideo']['coverPhoto']['urlMobileSized'];
    }

    List<AllPostsCategory>? allPostsCategory;
    if(json['categories'] != null) {
      allPostsCategory = (json['categories'] as List).map((v) => AllPostsCategory.fromJson(v)).toList();
    }

    return StoryListItem(
      id: json[BaseModel.idKey],
      name: json[BaseModel.nameKey],
      slug: json[BaseModel.slugKey],
      style: json['style'],
      photoUrl: photoUrl,
      category: allPostsCategory,
      publishTime: json['publishTime']
    );
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

class AllPostsCategory{
  String id;
  String name;

  AllPostsCategory({
    required this.id,
    required this.name
  });

  factory AllPostsCategory.fromJson(Map<String, dynamic> json){
    return AllPostsCategory(id: json['id'], name: json['name']);
  }
}
