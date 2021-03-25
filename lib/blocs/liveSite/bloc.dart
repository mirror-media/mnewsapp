import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/liveSite/events.dart';
import 'package:tv/blocs/liveSite/states.dart';
import 'package:tv/services/youtubePlaylistService.dart';

class LiveSiteBloc extends Bloc<LiveSiteEvents, LiveSiteState> {
  final YoutubePlaylistRepos youtubePlaylistRepos;

  LiveSiteBloc({this.youtubePlaylistRepos}) : super(LiveSiteInitState());

  @override
  Stream<LiveSiteState> mapEventToState(LiveSiteEvents event) async* {
    yield* event.run(youtubePlaylistRepos);
  }
}
