import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/anchorperson/events.dart';
import 'package:tv/blocs/anchorperson/states.dart';
import 'package:tv/services/anchorpersonService.dart';

class AnchorpersonBloc extends Bloc<AnchorpersonEvents, AnchorpersonState> {
  final AnchorpersonRepos anchorpersonRepos;

  AnchorpersonBloc({this.anchorpersonRepos}) : super(AnchorpersonInitState());

  @override
  Stream<AnchorpersonState> mapEventToState(AnchorpersonEvents event) async* {
    yield* event.run(anchorpersonRepos);
  }
}
