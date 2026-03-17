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
  final ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<List<YoutubePlaylistItem>> fetchAllPromotionVideos() async {
    const String query = """
    query {
      promotionVideos(
        where: {
          state: { equals: "published" }
        }
        orderBy: [{ sortOrder: asc }, { updatedAt: desc }]
      ) {
        ytUrl
      }
    }
    """;

    final Map<String, dynamic> variables = {};

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

    final List<YoutubePlaylistItem> youtubePlaylistItemList =
    List<YoutubePlaylistItem>.from(
      jsonResponse['data']['promotionVideos'].map(
            (ytVideo) => YoutubePlaylistItem.fromPromotionVideosJson(ytVideo),
      ),
    );

    final List<int> removeIndex = [];
    for (int i = 0; i < youtubePlaylistItemList.length; i++) {
      final response =
      await http.get(Uri.parse(youtubePlaylistItemList[i].photoUrl));
      if (response.statusCode != 200) {
        removeIndex.add(i);
      }
    }

    for (final index in removeIndex.reversed) {
      youtubePlaylistItemList.removeAt(index);
    }

    return youtubePlaylistItemList;
  }
}