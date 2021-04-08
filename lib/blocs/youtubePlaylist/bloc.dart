import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/youtubePlaylist/events.dart';
import 'package:tv/blocs/youtubePlaylist/states.dart';
import 'package:tv/services/youtubePlaylistService.dart';

class YoutubePlaylistBloc extends Bloc<YoutubePlaylistEvents, YoutubePlaylistState> {
  final YoutubePlaylistRepos youtubePlaylistRepos;

  YoutubePlaylistBloc({this.youtubePlaylistRepos}) : super(YoutubePlaylistInitState());

  @override
  Stream<YoutubePlaylistState> mapEventToState(YoutubePlaylistEvents event) async* {
    yield* event.run(youtubePlaylistRepos);
  }
}
