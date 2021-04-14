import 'dart:convert';

class Annotation {
  String text;
  String annotation;
  String pureAnnotationText;
  bool isExpanded;

  Annotation({
    this.text,
    this.annotation,
    this.pureAnnotationText,
    this.isExpanded,
  });

  factory Annotation.fromJson(Map<String, dynamic> json) {
    return Annotation(
      text: json['text'],
      annotation: json['annotation'],
      pureAnnotationText: json['pureAnnotationText'],
      isExpanded: json['isExpanded'] == null ? false : json['isExpanded'],
    );
  }

  factory Annotation.parseResponseBody(String body) {
    final jsonData = json.decode(body);

    return Annotation.fromJson(jsonData);
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'annotation': annotation,
        'pureAnnotationText': pureAnnotationText,
        'isExpanded': isExpanded,
      };
}
