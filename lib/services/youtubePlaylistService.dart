import 'package:tv/baseConfig.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/models/youtubePlaylistItemList.dart';

abstract class YoutubePlaylistRepos {
  Future<YoutubePlaylistItemList> fetchSnippetByPlaylistId(String playlistId,
      {int maxResults = 5});
  Future<YoutubePlaylistItemList> fetchSnippetByPlaylistIdAndPageToken(
      String playlistId, String pageToken,
      {int maxResults = 5});
}

class YoutubePlaylistServices implements YoutubePlaylistRepos {
  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<YoutubePlaylistItemList> fetchSnippetByPlaylistId(String playlistId,
      {int maxResults = 5}) async {
    final jsonResponse = await _helper.getByCacheAndAutoCache(
        baseConfig!.youtubeApi +
            '/playlistItems?part=snippet&playlistId=$playlistId&maxResults=$maxResults',
        maxAge: youtubePlayListCacheDuration);

    YoutubePlaylistItemList youtubePlaylistItemList =
        YoutubePlaylistItemList.fromJson(
            jsonResponse['nextPageToken'], jsonResponse['items']);
    return youtubePlaylistItemList;
  }

  @override
  Future<YoutubePlaylistItemList> fetchSnippetByPlaylistIdAndPageToken(
      String playlistId, String pageToken,
      {int maxResults = 5}) async {
    final jsonResponse = await _helper.getByUrl(baseConfig!.youtubeApi +
        '/playlistItems?part=snippet&playlistId=$playlistId&pageToken=$pageToken&maxResults=$maxResults');

    YoutubePlaylistItemList youtubePlaylistItemList =
        YoutubePlaylistItemList.fromJson(
            jsonResponse['nextPageToken'], jsonResponse['items']);
    return youtubePlaylistItemList;
  }
}
