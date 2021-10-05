abstract class ContactEvents {}

class FetchAnchorpersonOrHostContactList extends ContactEvents {
  FetchAnchorpersonOrHostContactList();

  @override
  String toString() => 'FetchAnchorpersonOrHostContactList';
}

class FetchContactById extends ContactEvents {
  final String contactId;
  FetchContactById(this.contactId);

  @override
  String toString() => 'FetchContactById : { ContactId : $contactId }';
}
