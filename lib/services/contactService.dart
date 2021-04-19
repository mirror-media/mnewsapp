import 'dart:convert';

import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/apiConstants.dart';
import 'package:tv/models/contact.dart';
import 'package:tv/models/contactList.dart';
import 'package:tv/models/graphqlBody.dart';

abstract class ContactRepos {
  Future<Contact> fetchContactById(String contactId);
  Future<ContactList> fetchContactList();
}

class ContactServices implements ContactRepos{
  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<ContactList> fetchContactList() async {
    String query = 
    """
    query {
      allContacts(
        where: {
          anchorperson: true
        }
      ) {
        id
        name
        image {
          urlMobileSized
        }
        slug
      }
    }
    """;

    Map<String,String> variables = {};

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
      graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      headers: {
        "Content-Type": "application/json"
      }
    );

    ContactList contactList = ContactList.fromJson(jsonResponse['data']['allContacts']);
    return contactList;
  }

  @override
  Future<Contact> fetchContactById(String contactId) async{
    String query = 
    """
    query(\$where: ContactWhereUniqueInput!) {
      Contact(where: \$where) {
        name
        image {
          urlMobileSized
        }
        twitter
        facebook
        instatgram
        bio
      }
    }
    """;

    Map<String,dynamic> variables = {
      "where": {
        "id": contactId
      }
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
      graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      headers: {
        "Content-Type": "application/json"
      }
    );

    Contact contact = Contact.fromJson(jsonResponse['data']['Contact']);
    return contact;
  }
}
