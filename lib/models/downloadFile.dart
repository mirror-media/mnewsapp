class DownloadFile {
  final String title;
  final String url;

  const DownloadFile({required this.title, required this.url});

  factory DownloadFile.fromJson(Map<String, dynamic> json) {
    return DownloadFile(title: json['name'], url: json['url']);
  }
}
