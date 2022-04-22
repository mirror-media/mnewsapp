import 'dart:convert';

import 'package:tv/helpers/environment.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/models/contact.dart';
import 'package:tv/models/graphqlBody.dart';

abstract class ContactRepos {
  Future<Contact> fetchContactById(String contactId);
  Future<List<Contact>> fetchAnchorpersonOrHostContactList();
}

class ContactServices implements ContactRepos {
  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<List<Contact>> fetchAnchorpersonOrHostContactList() async {
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
        sortBy:[sortOrder_ASC]
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
        key, Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
        maxAge: anchorPersonListCacheDuration,
        headers: {"Content-Type": "application/json"});

    List<Contact> contactList = List<Contact>.from(jsonResponse['data']
            ['allContacts']
        .map((contact) => Contact.fromJson(contact)));

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
        showhostImg {
          urlMobileSized
        }
        slug
        twitter
        facebook
        instagram
        bioApiData
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
        key, Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
        maxAge: anchorPersonCacheDuration,
        headers: {"Content-Type": "application/json"});

    Contact contact = Contact.fromJson(jsonResponse['data']['Contact']);
    return contact;
  }
}
