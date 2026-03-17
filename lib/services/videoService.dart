import 'dart:convert';

import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/video.dart';

abstract class VideoRepos {
  Future<Video> fetchVideoByName(String name);
}

class VideoServices implements VideoRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<Video> fetchVideoByName(String name) async {
    const String query = """
    query(
      \$where: VideoWhereInput
    ){
      videos(
        where: \$where
      ){
        url
      }
    }    
    """;

    final Map<String, dynamic> variables = {
      "where": {
        "name": {"equals": name}
      }
    };

    final GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
      Environment().config.graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      headers: {"Content-Type": "application/json"},
    );

    try {
      return Video.fromJson(jsonResponse['data']['videos'][0]);
    } catch (e) {
      throw FormatException(e.toString());
    }
  }
}