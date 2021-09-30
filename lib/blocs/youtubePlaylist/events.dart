abstract class YoutubePlaylistEvents {}

class FetchSnippetByPlaylistId extends YoutubePlaylistEvents {
  final String playlistId;
  final int maxResults;
  FetchSnippetByPlaylistId(this.playlistId, {this.maxResults = 5});

  @override
  String toString() =>
      'FetchSnippetByPlaylistId { storySlug: $playlistId, maxResults: $maxResults }';
}

class FetchSnippetByPlaylistIdAndPageToken extends YoutubePlaylistEvents {
  final String playlistId;
  final String pageToken;
  final int maxResults;
  FetchSnippetByPlaylistIdAndPageToken(this.playlistId, this.pageToken,
      {this.maxResults = 5});

  @override
  String toString() =>
      'FetchSnippetByPlaylistIdAndPageToken { playlistId: $playlistId, pageToken: $pageToken, maxResults: $maxResults }';
}
