import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/contact/events.dart';
import 'package:tv/blocs/contact/states.dart';
import 'package:tv/services/contactService.dart';

class ContactBloc extends Bloc<ContactEvents, ContactState> {
  final ContactRepos contactRepos;

  ContactBloc({this.contactRepos}) : super(ContactInitState());

  @override
  Stream<ContactState> mapEventToState(ContactEvents event) async* {
    yield* event.run(contactRepos);
  }
}
