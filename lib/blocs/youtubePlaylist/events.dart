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
  final int maxResults;
  FetchSnippetByPlaylistIdAndPageToken(this.playlistId, {this.maxResults = 5});

  @override
  String toString() =>
      'FetchSnippetByPlaylistIdAndPageToken { playlistId: $playlistId, maxResults: $maxResults }';
}
