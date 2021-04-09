import 'dart:convert';

import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/apiConstants.dart';
import 'package:tv/models/anchorpersonList.dart';
import 'package:tv/models/graphqlBody.dart';

abstract class AnchorpersonRepos {
  Future<AnchorpersonList> fetchAnchorpersonList();
}

class AnchorpersonServices implements AnchorpersonRepos{
  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<AnchorpersonList> fetchAnchorpersonList() async {
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

    AnchorpersonList anchorpersonList = AnchorpersonList.fromJson(jsonResponse['data']['allContacts']);
    return anchorpersonList;
  }
}
