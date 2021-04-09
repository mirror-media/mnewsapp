import 'package:tv/helpers/apiConstants.dart';

class Anchorperson {
  final String id;
  final String name;
  final String photoUrl;
  final String slug;

  Anchorperson({
    this.id,
    this.name,
    this.photoUrl,
    this.slug,
  });

  factory Anchorperson.fromJson(Map<String, dynamic> json) {
    String photoUrl = mirrorNewsDefaultImageUrl;
    if (json['image'] != null && 
      json['image']['urlMobileSized'] != null) {
      photoUrl = json['image']['urlMobileSized'];
    }
    
    return Anchorperson(
      id: json['id'],
      name: json['name'],
      photoUrl: photoUrl,
      slug: json['slug'],
    );
  }
}