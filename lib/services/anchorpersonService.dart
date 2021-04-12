import 'dart:convert';

import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/apiConstants.dart';
import 'package:tv/models/anchorperson.dart';
import 'package:tv/models/anchorpersonList.dart';
import 'package:tv/models/graphqlBody.dart';

abstract class AnchorpersonRepos {
  Future<Anchorperson> fetchAnchorpersonById(String anchorpersonId);
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

  @override
  Future<Anchorperson> fetchAnchorpersonById(String anchorpersonId) async{
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
        "id": anchorpersonId
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

    Anchorperson anchorperson = Anchorperson.fromJson(jsonResponse['data']['Contact']);
    return anchorperson;
  }
}
