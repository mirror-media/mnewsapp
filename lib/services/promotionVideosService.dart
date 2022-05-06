import 'dart:convert';

import 'package:tv/helpers/environment.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:http/http.dart' as http;

abstract class PromotionVideosRepos {
  Future<List<YoutubePlaylistItem>> fetchAllPromotionVideos();
}

class PromotionVideosServices implements PromotionVideosRepos {
  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<List<YoutubePlaylistItem>> fetchAllPromotionVideos() async {
    final String query = """
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
        Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
        headers: {"Content-Type": "application/json"});

    List<YoutubePlaylistItem> youtubePlaylistItemList =
        List<YoutubePlaylistItem>.from(
            jsonResponse['data']['allPromotionVideos'].map((ytVideo) =>
                YoutubePlaylistItem.fromPromotionVideosJson(ytVideo)));
    List<int> removeIndex = [];
    for (int i = 0; i < youtubePlaylistItemList.length; i++) {
      final reponse =
          await http.get(Uri.parse(youtubePlaylistItemList[i].photoUrl));
      if (reponse.statusCode != 200) {
        removeIndex.add(i);
      }
    }
    for (var index in removeIndex) {
      youtubePlaylistItemList.removeAt(index);
    }
    return youtubePlaylistItemList;
  }
}
