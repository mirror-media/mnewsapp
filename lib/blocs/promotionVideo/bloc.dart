import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/promotionVideo/events.dart';
import 'package:tv/blocs/promotionVideo/states.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:tv/services/promotionVideosService.dart';

class PromotionVideoBloc
    extends Bloc<PromotionVideoEvents, PromotionVideoState> {
  final PromotionVideosRepos promotionVideosRepos;

  PromotionVideoBloc({required this.promotionVideosRepos})
      : super(PromotionVideoInitState()) {
    on<PromotionVideoEvents>(
      (event, emit) async {
        print(event.toString());
        try {
          if (event is FetchAllPromotionVideos) {
            emit(PromotionVideoLoading());
            List<YoutubePlaylistItem> youtubePlaylistItemList =
                await promotionVideosRepos.fetchAllPromotionVideos();
            emit(PromotionVideoLoaded(
                youtubePlaylistItemList: youtubePlaylistItemList));
          }
        } catch (e) {
          emit(PromotionVideoError(
            error: determineException(e),
          ));
        }
      },
    );
  }
}
