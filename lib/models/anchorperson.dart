import 'package:tv/helpers/apiConstants.dart';

class Anchorperson {
  final String name;
  final String photoUrl;
  final String slug;

  Anchorperson({
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
      name: json['name'],
      photoUrl: photoUrl,
      slug: json['slug'],
    );
  }
}