import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/show/events.dart';
import 'package:tv/blocs/show/states.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/models/showIntro.dart';
import 'package:tv/services/showService.dart';

class ShowIntroBloc extends Bloc<ShowEvents, ShowState> {
  final ShowRepos showRepos;

  ShowIntroBloc({required this.showRepos}) : super(ShowInitState()) {
    on<ShowEvents>(
      (event, emit) async {
        print(event.toString());
        try {
          emit(ShowLoading());
          if (event is FetchShowIntro) {
            ShowIntro showIntro =
                await showRepos.fetchShowIntroById(event.showCategoryId);
            emit(ShowIntroLoaded(showIntro: showIntro));
          }
        } catch (e) {
          emit(ShowError(
            error: determineException(e),
          ));
        }
      },
    );
  }
}
