import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/section/events.dart';
import 'package:tv/blocs/section/states.dart';
import 'package:tv/services/sectionService.dart';

class SectionBloc extends Bloc<SectionEvents, SectionState> {
  final SectionRepos sectionRepos;

  SectionBloc({this.sectionRepos}) : super(SectionInitState());

  @override
  Stream<SectionState> mapEventToState(SectionEvents event) async* {
    yield* event.run(sectionRepos);
  }
}
