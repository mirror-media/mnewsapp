import 'dart:convert';

import 'package:tv/baseConfig.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/youtubePlaylistItemList.dart';

abstract class PromotionVideosRepos {
  Future<YoutubePlaylistItemList> fetchAllPromotionVideos();
}

class PromotionVideosServices implements PromotionVideosRepos{
  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<YoutubePlaylistItemList> fetchAllPromotionVideos() async{
    final String query = 
    """
    query {
      allPromotionVideos(
        where: {
          state: published
        }
        sortBy: [ sortOrder_ASC, updatedAt_DESC ]
      ) {
        ytUrl
      }
    }
    """;

    Map<String, dynamic> variables = {};

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
      baseConfig!.graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      headers: {
        "Content-Type": "application/json"
      }
    );

    YoutubePlaylistItemList youtubePlaylistItemList = YoutubePlaylistItemList.fromPromotionVideosJson(jsonResponse['data']['allPromotionVideos']);
    return youtubePlaylistItemList;
  }
}