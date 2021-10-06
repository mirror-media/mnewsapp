import 'dart:convert';

import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:youtube_plyr_iframe/youtube_plyr_iframe.dart';

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
        Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
        headers: {"Content-Type": "application/json"});

    String? youtubeId;
    try {
      youtubeId = YoutubePlayerController.convertUrlToId(
          jsonResponse['data']['Video']['youtubeUrl']);
    } catch (e) {
      throw FormatException(e.toString());
    }
    return youtubeId ?? '';
  }

  Future<List<String>> fetchLiveIdByPostCategory(String category) async {
    final String query = """
    query(
      \$where: VideoWhereInput!,
    ){
     allVideos(
        where: \$where
        sortBy: [ publishTime_DESC ]
      ){
        youtubeUrl
      }
    }    
    """;

    Map<String, dynamic> variables = {
      "where": {
        "categories_some": {"slug_in": category}
      }
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
        Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
        headers: {"Content-Type": "application/json"});

    List<String> youtubeIdList = [];
    try {
      if (jsonResponse['data']['allVideos'] != null) {
        jsonResponse['data']['allVideos'].forEach((video) {
          if (video['youtubeUrl'] != null) {
            String? youtubeId =
                YoutubePlayerController.convertUrlToId(video['youtubeUrl']);
            if (youtubeId != null) youtubeIdList.add(youtubeId);
          }
        });
      }
    } catch (e) {
      throw FormatException(e.toString());
    }
    return youtubeIdList;
  }
}
