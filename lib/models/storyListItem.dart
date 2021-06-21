import 'package:tv/baseConfig.dart';
import 'package:tv/models/baseModel.dart';

class StoryListItem {
  String? id;
  String name;
  String slug;
  String? style;
  String photoUrl;

  StoryListItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.style,
    required this.photoUrl,
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
