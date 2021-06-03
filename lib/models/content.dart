class Content {
  String data;
  double? aspectRatio;
  String? description;

  Content({
    required this.data,
    required this.aspectRatio,
    required this.description,
  });

  factory Content.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      if (json['mobile'] != null) {
        return Content(
          data: json['mobile']['url'],
          aspectRatio: json['mobile']['width'] / json['mobile']['height'],
          description: json['title'],
        );
      } else if (json['youtubeId'] != null) {
        return Content(
          data: json['youtubeId'],
          aspectRatio: null,
          description: json['description'],
        );
      } 
      // audio or video
      else if (json['url'] != null) {
        return Content(
          data: json['url'],
          aspectRatio: null,
          description: json['name'],
        );
      } 
      else if (json['embeddedCode'] != null) {
        return Content(
          data: json['embeddedCode'],
          aspectRatio: (json['width'] == null || json['height'] == null)
            ? null
            : double.parse(json['width'])/double.parse(json['height']),
          description: json['caption'],
        );
      } else if (json['draftRawObj'] != null) {
        return Content(
          data: json['body'],
          aspectRatio: null,
          description: json['title'],
        );
      } else if (json['quote'] != null) {
        return Content(
          data: json['quote'],
          aspectRatio: null,
          description: json['quoteBy'],
        );
      }
    }

    return Content(
      data: json.toString(),
      aspectRatio: null,
      description: null,
    );
  }
}
