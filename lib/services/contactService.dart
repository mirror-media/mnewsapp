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
  final ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<List<Contact>> fetchAnchorpersonOrHostContactList() async {
    final key = 'fetchAnchorpersonOrHostContactList';

    const String query = """
    query {
      contacts(
        where: {
          OR: [
            {
              anchorperson: { equals: true }
            }
            {
              host: { equals: true }
            }
          ]
        }
        orderBy: [{ sortOrder: asc }]
      ) {
        id
        name
        anchorImg {
          imageApiData
        }
        slug
        anchorperson
        host
      }
    }
    """;

    final GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: {},
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
      key,
      Environment().config.graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      maxAge: anchorPersonListCacheDuration,
      headers: {"Content-Type": "application/json"},
    );

    final List<Contact> contactList = List<Contact>.from(
      jsonResponse['data']['contacts'].map((contact) => Contact.fromJson(contact)),
    );

    return contactList;
  }

  @override
  Future<Contact> fetchContactById(String contactId) async {
    final key = 'fetchContactById?contactId=$contactId';

    const String query = """
    query(\$where: ContactWhereUniqueInput!) {
      contact(where: \$where) {
        id
        name
        showhostImg {
          imageApiData
        }
        slug
        twitter
        facebook
        instagram
        bioApiData
      }
    }
    """;

    final Map<String, dynamic> variables = {
      "where": {"id": contactId}
    };

    final GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
      key,
      Environment().config.graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      maxAge: anchorPersonCacheDuration,
      headers: {"Content-Type": "application/json"},
    );

    final Contact contact = Contact.fromJson(jsonResponse['data']['contact']);
    return contact;
  }
}