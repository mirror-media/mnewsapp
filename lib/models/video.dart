class Video {
  final String? url;
  final String? ytUrl;

  Video({this.url, this.ytUrl});

  factory Video.fromJson(Map<String, dynamic> json) {
    String? ytUrl;
    if (json['youtubeUrl'] != null) {
      ytUrl = json['youtubeUrl'];
    }
    return Video(
      url: json['url'],
      ytUrl: ytUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'youtubeUrl': ytUrl,
      };
}
