import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/youtubePlaylist/events.dart';
import 'package:tv/blocs/youtubePlaylist/states.dart';
import 'package:tv/models/youtubePlaylistItemList.dart';
import 'package:tv/services/youtubePlaylistService.dart';

class YoutubePlaylistBloc
    extends Bloc<YoutubePlaylistEvents, YoutubePlaylistState> {
  final YoutubePlaylistRepos youtubePlaylistRepos;
  YoutubePlaylistItemList youtubePlaylistItemList = YoutubePlaylistItemList();

  YoutubePlaylistBloc({required this.youtubePlaylistRepos})
      : super(YoutubePlaylistInitState());

  @override
  Stream<YoutubePlaylistState> mapEventToState(
      YoutubePlaylistEvents event) async* {
    event.youtubePlaylistItemList = youtubePlaylistItemList;
    yield* event.run(youtubePlaylistRepos);
    youtubePlaylistItemList = event.youtubePlaylistItemList;
  }
}
