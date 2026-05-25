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
    final String requestUrl = Environment().config.youtubeApi +
        '/playlistItems?part=snippet&playlistId=$playlistId&maxResults=$maxResults';
    // ===== 選單排查 log =====
    print('[選單排查] YoutubePlaylistService 請求 URL=$requestUrl');
    final jsonResponse = await _helper.getByCacheAndAutoCache(requestUrl,
        maxAge: youtubePlayListCacheDuration);

    // ===== 選單排查 log =====
    print('[選單排查] YoutubePlaylistService 回應 '
        'keys=${jsonResponse is Map ? jsonResponse.keys.toList() : jsonResponse.runtimeType} '
        'itemsCount=${jsonResponse is Map && jsonResponse['items'] is List ? (jsonResponse['items'] as List).length : "N/A(可能是錯誤回應)"}');

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
