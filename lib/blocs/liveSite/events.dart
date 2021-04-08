import 'dart:io';

import 'package:tv/blocs/liveSite/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/youtubePlaylistItemList.dart';
import 'package:tv/services/youtubePlaylistService.dart';

abstract class LiveSiteEvents{
  Stream<LiveSiteState> run(YoutubePlaylistRepos youtubePlaylistRepos);
}

class FetchSnippetByPlaylistId extends LiveSiteEvents {
  final String playlistId;
  final int maxResult;
  FetchSnippetByPlaylistId(this.playlistId, {this.maxResult = 5});

  @override
  String toString() => 'FetchSnippetByPlaylistId { storySlug: $playlistId, maxResult: $maxResult }';

  @override
  Stream<LiveSiteState> run(YoutubePlaylistRepos youtubePlaylistRepos) async*{
    print(this.toString());
    try{
      yield LiveSiteLoading();
      YoutubePlaylistItemList youtubePlaylistItemList = 
          await youtubePlaylistRepos.fetchSnippetByPlaylistId(playlistId, maxResults: maxResult);
      yield LiveSiteLoaded(youtubePlaylistItemList: youtubePlaylistItemList);
    } on SocketException {
      yield LiveSiteError(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      yield LiveSiteError(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      yield LiveSiteError(
        error: InvalidFormatException('Invalid Response format'),
      );
    } catch (e) {
      yield LiveSiteError(
        error: UnknownException(e.toString()),
      );
    }
  }
}