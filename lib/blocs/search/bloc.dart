import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/search/events.dart';
import 'package:tv/blocs/search/states.dart';
import 'package:tv/services/searchService.dart';

class SearchBloc extends Bloc<SearchEvents, SearchState> {
  final SearchRepos searchRepos;

  SearchBloc({this.searchRepos}) : super(SearchInitState());

  @override
  Stream<SearchState> mapEventToState(SearchEvents event) async* {
    yield* event.run(searchRepos);
  }
}
