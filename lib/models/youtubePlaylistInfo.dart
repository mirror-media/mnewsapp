class YoutubePlaylistInfo {
  final String name;
  final String youtubePlayListId;

  YoutubePlaylistInfo({
    this.name,
    this.youtubePlayListId,
  });

  factory YoutubePlaylistInfo.parseByShow(String json, String defaultName) {
    String name;
    String youtubePlayListId;

    if(json != null) {
      List<String> info = json.split('：');
      name = info.length < 2 ? defaultName : info[1];
      youtubePlayListId = info[0].split('playlist?list=')[1]; 
    }

    return YoutubePlaylistInfo(
      name: name,
      youtubePlayListId: youtubePlayListId,
    );
  }
}