import 'package:tv/helpers/apiConstants.dart';

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
    if(json.containsKey('_source') && json['_source'] != null) {
      json = json['_source'];
    }

    String photoUrl = mirrorNewsDefaultImageUrl;
    if (json['heroImage'] != null && 
      json['heroImage']['urlMobileSized'] != null) {
      photoUrl = json['heroImage']['urlMobileSized'];
    } else if (json['heroVideo'] != null && 
      json['heroVideo']['coverPhoto'] != null && 
      json['heroVideo']['coverPhoto']['urlMobileSized'] != null) {
      photoUrl = json['heroVideo']['coverPhoto']['urlMobileSized'];
    }

    return StoryListItem(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      style: json['style'],
      photoUrl: photoUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
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
