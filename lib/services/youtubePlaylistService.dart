import 'package:tv/helpers/environment.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/models/youtubePlaylistItem.dart';

abstract class YoutubePlaylistRepos {
  Future<List<YoutubePlaylistItem>> fetchSnippetByPlaylistId(String playlistId,
      {int maxResults = 5});
  Future<List<YoutubePlaylistItem>> fetchSnippetByPlaylistIdAndPageToken(
      String playlistId,
      {int maxResults = 5});
}

class YoutubePlaylistServices implements YoutubePlaylistRepos {
  ApiBaseHelper _helper = ApiBaseHelper();
  String? _nextPageToken;

  @override
  Future<List<YoutubePlaylistItem>> fetchSnippetByPlaylistId(String playlistId,
      {int maxResults = 5}) async {
    final jsonResponse = await _helper.getByCacheAndAutoCache(
        Environment().config.youtubeApi +
            '/playlistItems?part=snippet&playlistId=$playlistId&maxResults=$maxResults',
        maxAge: youtubePlayListCacheDuration);

    _nextPageToken = jsonResponse['nextPageToken'];

    List<YoutubePlaylistItem> youtubePlaylistItemList =
        List<YoutubePlaylistItem>.from(jsonResponse['items']
            .map((ytVideo) => YoutubePlaylistItem.fromJson(ytVideo)));

    youtubePlaylistItemList
        .removeWhere((element) => element.name == 'Private video');
    return youtubePlaylistItemList;
  }

  @override
  Future<List<YoutubePlaylistItem>> fetchSnippetByPlaylistIdAndPageToken(
      String playlistId,
      {int maxResults = 5}) async {
    if (_nextPageToken == null) {
      return [];
    }
    final jsonResponse = await _helper.getByUrl(Environment()
            .config
            .youtubeApi +
        '/playlistItems?part=snippet&playlistId=$playlistId&pageToken=$_nextPageToken&maxResults=$maxResults');

    _nextPageToken = jsonResponse['nextPageToken'];

    List<YoutubePlaylistItem> youtubePlaylistItemList =
        List<YoutubePlaylistItem>.from(jsonResponse['items']
            .map((ytVideo) => YoutubePlaylistItem.fromJson(ytVideo)));

    youtubePlaylistItemList
        .removeWhere((element) => element.name == 'Private video');
    return youtubePlaylistItemList;
  }
}
