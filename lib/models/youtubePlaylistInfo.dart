class YoutubePlaylistInfo {
  final String name;
  final String youtubePlayListId;

  YoutubePlaylistInfo({
    required this.name,
    required this.youtubePlayListId,
  });

  static YoutubePlaylistInfo? parseByShow(String? json, String defaultName) {
    if (json == null) {
      return null;
    }

    List<String> info = json.split('：');
    String name = info.length < 2 ? defaultName : info[1];
    String youtubePlayListId = info[0].split('playlist?list=')[1];
    return YoutubePlaylistInfo(
      name: name,
      youtubePlayListId: youtubePlayListId,
    );
  }
}
