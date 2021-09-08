import 'dart:convert';

import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/video.dart';

import '../baseConfig.dart';

abstract class VideoRepos {
  Future<Video> fetchVideoByName(String name);
}

class VideoServices implements VideoRepos {
  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<Video> fetchVideoByName(String name) async {
    final String query = """
    query(
      \$where: VideoWhereInput,
    ){
      allVideos(
        where: \$where
      ){
        url
      }
    }    
    """;

    Map<String, dynamic> variables = {
      "where": {"name": name},
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
        baseConfig!.graphqlApi, jsonEncode(graphqlBody.toJson()),
        headers: {"Content-Type": "application/json"});

    Video video;
    try {
      video = Video.fromJson(jsonResponse['data']['allVideos'][0]);
    } catch (e) {
      throw FormatException(e.toString());
    }
    return video;
  }
}
