import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/promotionVideo/events.dart';
import 'package:tv/blocs/promotionVideo/states.dart';
import 'package:tv/services/promotionVideosService.dart';

class PromotionVideoBloc extends Bloc<PromotionVideoEvents, PromotionVideoState> {
  final PromotionVideosRepos promotionVideosRepos;

  PromotionVideoBloc({required this.promotionVideosRepos}) : super(PromotionVideoInitState());

  @override
  Stream<PromotionVideoState> mapEventToState(PromotionVideoEvents event) async* {
    yield* event.run(promotionVideosRepos);
  }
}
