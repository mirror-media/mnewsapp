import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tv/blocs/youtubePlaylist/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/youtubePlaylistItemList.dart';
import 'package:tv/services/youtubePlaylistService.dart';

abstract class YoutubePlaylistEvents {
  YoutubePlaylistItemList youtubePlaylistItemList = YoutubePlaylistItemList();
  Stream<YoutubePlaylistState> run(YoutubePlaylistRepos youtubePlaylistRepos);
}

class FetchSnippetByPlaylistId extends YoutubePlaylistEvents {
  final String playlistId;
  final int maxResults;
  FetchSnippetByPlaylistId(this.playlistId, {this.maxResults = 5});

  @override
  String toString() =>
      'FetchSnippetByPlaylistId { storySlug: $playlistId, maxResults: $maxResults }';

  @override
  Stream<YoutubePlaylistState> run(
      YoutubePlaylistRepos youtubePlaylistRepos) async* {
    print(this.toString());
    try {
      yield YoutubePlaylistLoading();
      youtubePlaylistItemList = await youtubePlaylistRepos
          .fetchSnippetByPlaylistId(playlistId, maxResults: maxResults);
      yield YoutubePlaylistLoaded(
          youtubePlaylistItemList: youtubePlaylistItemList);
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

class FetchSnippetByPlaylistIdAndPageToken extends YoutubePlaylistEvents {
  final String playlistId;
  final String pageToken;
  final int maxResults;
  FetchSnippetByPlaylistIdAndPageToken(this.playlistId, this.pageToken,
      {this.maxResults = 5});

  @override
  String toString() =>
      'FetchSnippetByPlaylistIdAndPageToken { playlistId: $playlistId, pageToken: $pageToken, maxResults: $maxResults }';

  @override
  Stream<YoutubePlaylistState> run(
      YoutubePlaylistRepos youtubePlaylistRepos) async* {
    print(this.toString());
    try {
      yield YoutubePlaylistLoadingMore(
          youtubePlaylistItemList: youtubePlaylistItemList);
      YoutubePlaylistItemList newYoutubePlaylistItemList =
          await youtubePlaylistRepos.fetchSnippetByPlaylistIdAndPageToken(
              playlistId, pageToken,
              maxResults: maxResults);
      youtubePlaylistItemList.nextPageToken =
          newYoutubePlaylistItemList.nextPageToken;
      youtubePlaylistItemList.addAll(newYoutubePlaylistItemList);

      yield YoutubePlaylistLoaded(
          youtubePlaylistItemList: youtubePlaylistItemList);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "加載失敗",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      await Future.delayed(Duration(seconds: 5));
      yield YoutubePlaylistLoadingMoreFail(
          youtubePlaylistItemList: youtubePlaylistItemList);
    }
  }
}
