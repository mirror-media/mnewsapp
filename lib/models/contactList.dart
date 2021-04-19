import 'dart:convert';

import 'package:tv/models/contact.dart';
import 'package:tv/models/customizedList.dart';

class ContactList extends CustomizedList<Contact> {
  // constructor
  ContactList();

  factory ContactList.fromJson(List<dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }

    ContactList contacts = ContactList();
    List parseList = parsedJson.map((i) => Contact.fromJson(i)).toList();
    parseList.forEach((element) {
      contacts.add(element);
    });

    return contacts;
  }

  factory ContactList.parseResponseBody(String body) {
    final jsonData = json.decode(body);

    return ContactList.fromJson(jsonData);
  }
}
