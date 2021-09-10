import 'dart:convert';

import 'package:tv/baseConfig.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/models/contact.dart';
import 'package:tv/models/contactList.dart';
import 'package:tv/models/graphqlBody.dart';

abstract class ContactRepos {
  Future<Contact> fetchContactById(String contactId);
  Future<ContactList> fetchAnchorpersonOrHostContactList();
}

class ContactServices implements ContactRepos {
  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<ContactList> fetchAnchorpersonOrHostContactList() async {
    final key = 'fetchAnchorpersonOrHostContactList';

    String query = """
    query {
      allContacts(
        where: {
          OR: [
            {
              anchorperson: true
            }
            {
              host: true
            }
          ]
        }
      ) {
        id
        name
        anchorImg {
          urlMobileSized
        }
        slug
        anchorperson
        host
      }
    }
    """;

    Map<String, String> variables = {};

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
        key, baseConfig!.graphqlApi, jsonEncode(graphqlBody.toJson()),
        maxAge: anchorPersonListCacheDuration,
        headers: {"Content-Type": "application/json"});

    ContactList contactList =
        ContactList.fromJson(jsonResponse['data']['allContacts']);
    return contactList;
  }

  @override
  Future<Contact> fetchContactById(String contactId) async {
    final key = 'fetchContactById?contactId=$contactId';

    String query = """
    query(\$where: ContactWhereUniqueInput!) {
      Contact(where: \$where) {
        id
        name
        anchorImg {
          urlMobileSized
        }
        slug
        twitter
        facebook
        instagram
        bio
      }
    }
    """;

    Map<String, dynamic> variables = {
      "where": {"id": contactId}
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
        key, baseConfig!.graphqlApi, jsonEncode(graphqlBody.toJson()),
        maxAge: anchorPersonCacheDuration,
        headers: {"Content-Type": "application/json"});

    Contact contact = Contact.fromJson(jsonResponse['data']['Contact']);
    return contact;
  }
}
