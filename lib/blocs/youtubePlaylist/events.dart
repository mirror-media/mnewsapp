import 'dart:io';

import 'package:tv/blocs/youtubePlaylist/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/youtubePlaylistItemList.dart';
import 'package:tv/services/youtubePlaylistService.dart';

abstract class YoutubePlaylistEvents{
  Stream<YoutubePlaylistState> run(YoutubePlaylistRepos youtubePlaylistRepos);
}

class FetchSnippetByPlaylistId extends YoutubePlaylistEvents {
  final String playlistId;
  final int maxResult;
  FetchSnippetByPlaylistId(this.playlistId, {this.maxResult = 5});

  @override
  String toString() => 'FetchSnippetByPlaylistId { storySlug: $playlistId, maxResult: $maxResult }';

  @override
  Stream<YoutubePlaylistState> run(YoutubePlaylistRepos youtubePlaylistRepos) async*{
    print(this.toString());
    try{
      yield YoutubePlaylistLoading();
      YoutubePlaylistItemList youtubePlaylistItemList = 
          await youtubePlaylistRepos.fetchSnippetByPlaylistId(playlistId, maxResults: maxResult);
      yield YoutubePlaylistLoaded(youtubePlaylistItemList: youtubePlaylistItemList);
    } on SocketException {
      yield YoutubePlaylistError(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      yield YoutubePlaylistError(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      yield YoutubePlaylistError(
        error: InvalidFormatException('Invalid Response format'),
      );
    } catch (e) {
      yield YoutubePlaylistError(
        error: UnknownException(e.toString()),
      );
    }
  }
}