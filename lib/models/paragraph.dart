import 'package:tv/models/content.dart';

class Paragraph {
  String? styles;
  String? type;
  List<Content>? contents;

  Paragraph({
    this.styles,
    this.type,
    this.contents,
  });

  factory Paragraph.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Paragraph();
    }

    List<Content> contents = List<Content>.from(
        json["content"].map((content) => Content.fromJson(content)));

    return Paragraph(
      type: json['type'],
      contents: contents,
    );
  }
}
