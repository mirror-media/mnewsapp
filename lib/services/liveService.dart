import 'dart:convert';

import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/models/graphqlBody.dart';
import '../baseConfig.dart';

abstract class LiveRepos {
  Future<String> fetchLiveIdByPostId(String id);
}

class LiveServices implements LiveRepos {
  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<String> fetchLiveIdByPostId(String id) async {
    final String query = """
    query(
      \$where: VideoWhereUniqueInput!,
    ){
      Video(
        where: \$where
      ){
        youtubeUrl
      }
    }    
    """;

    Map<String, dynamic> variables = {
      "where": {"id": id}
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
        baseConfig!.graphqlApi, jsonEncode(graphqlBody.toJson()),
        headers: {"Content-Type": "application/json"});

    String youtubeId;
    try {
      var splitString = jsonResponse['data']['Video']['youtubeUrl'].split('=');
      youtubeId = splitString[1];
    } catch (e) {
      throw FormatException(e.toString());
    }
    return youtubeId;
  }
}
