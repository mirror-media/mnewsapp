import 'package:tv/models/contentList.dart';

class Paragraph {
  String styles;
  ContentList contents;
  String type;

  Paragraph({
    this.styles,
    this.contents,
    this.type,
  });

  factory Paragraph.fromJson(Map<String, dynamic> json) {
    if(json == null) {
      return Paragraph();
    }

    ContentList contents;
    contents = ContentList.fromJson(json["content"]);

    return Paragraph(
      type: json['type'],
      contents: contents,
    );
  }
}
