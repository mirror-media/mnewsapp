import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/anchorperson/events.dart';
import 'package:tv/blocs/anchorperson/states.dart';
import 'package:tv/services/contactService.dart';

class AnchorpersonBloc extends Bloc<AnchorpersonEvents, AnchorpersonState> {
  final ContactRepos contactRepos;

  AnchorpersonBloc({this.contactRepos}) : super(AnchorpersonInitState());

  @override
  Stream<AnchorpersonState> mapEventToState(AnchorpersonEvents event) async* {
    yield* event.run(contactRepos);
  }
}
