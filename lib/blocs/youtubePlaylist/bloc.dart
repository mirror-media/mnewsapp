import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tv/blocs/youtubePlaylist/events.dart';
import 'package:tv/blocs/youtubePlaylist/states.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:tv/services/youtubePlaylistService.dart';

class YoutubePlaylistBloc
    extends Bloc<YoutubePlaylistEvents, YoutubePlaylistState> {
  final YoutubePlaylistRepos youtubePlaylistRepos;
  List<YoutubePlaylistItem> youtubePlaylistItemList = [];

  YoutubePlaylistBloc({required this.youtubePlaylistRepos})
      : super(YoutubePlaylistInitState()) {
    on<YoutubePlaylistEvents>(
      (event, emit) async {
        print(event.toString());
        try {
          emit(YoutubePlaylistLoading());
          if (event is FetchSnippetByPlaylistId) {
            youtubePlaylistItemList = await youtubePlaylistRepos
                .fetchSnippetByPlaylistId(event.playlistId,
                    maxResults: event.maxResults);
            emit(YoutubePlaylistLoaded(
                youtubePlaylistItemList: youtubePlaylistItemList));
          } else if (event is FetchSnippetByPlaylistIdAndPageToken) {
            emit(YoutubePlaylistLoadingMore(
                youtubePlaylistItemList: youtubePlaylistItemList));
            List<YoutubePlaylistItem> newYoutubePlaylistItemList =
                await youtubePlaylistRepos.fetchSnippetByPlaylistIdAndPageToken(
                    event.playlistId,
                    maxResults: event.maxResults);
            youtubePlaylistItemList.addAll(newYoutubePlaylistItemList);

            emit(YoutubePlaylistLoaded(
                youtubePlaylistItemList: youtubePlaylistItemList));
          }
        } catch (e) {
          if (event is FetchSnippetByPlaylistIdAndPageToken) {
            Fluttertoast.showToast(
                msg: "加載失敗",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            await Future.delayed(Duration(seconds: 5));
            emit(YoutubePlaylistLoadingMoreFail(
                youtubePlaylistItemList: youtubePlaylistItemList));
          } else {
            emit(YoutubePlaylistError(
              error: determineException(e),
            ));
          }
        }
      },
    );
  }
}
