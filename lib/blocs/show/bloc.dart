import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/show/events.dart';
import 'package:tv/blocs/show/states.dart';
import 'package:tv/services/showService.dart';

class ShowIntroBloc extends Bloc<ShowEvents, ShowState> {
  final ShowRepos showRepos;

  ShowIntroBloc({required this.showRepos}) : super(ShowInitState());

  @override
  Stream<ShowState> mapEventToState(ShowEvents event) async* {
    yield* event.run(showRepos);
  }
}
