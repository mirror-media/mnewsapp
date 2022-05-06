import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/contact/events.dart';
import 'package:tv/blocs/contact/states.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/models/contact.dart';
import 'package:tv/services/contactService.dart';

class ContactBloc extends Bloc<ContactEvents, ContactState> {
  final ContactRepos contactRepos;

  ContactBloc({required this.contactRepos}) : super(ContactInitState()) {
    on<ContactEvents>(
      (event, emit) async {
        print(event.toString());
        try {
          emit(ContactLoading());
          if (event is FetchAnchorpersonOrHostContactList) {
            List<Contact> contactList =
                await contactRepos.fetchAnchorpersonOrHostContactList();
            emit(ContactListLoaded(contactList: contactList));
          } else if (event is FetchContactById) {
            Contact contact =
                await contactRepos.fetchContactById(event.contactId);
            emit(ContactLoaded(contact: contact));
          }
        } catch (e) {
          emit(ContactError(error: determineException(e)));
        }
      },
    );
  }
}
