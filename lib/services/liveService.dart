import 'dart:convert';

import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/liveCamItem.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

abstract class LiveRepos {
  Future<String> fetchLiveIdByPostId(String id);
}

class LiveServices implements LiveRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<String> fetchLiveIdByPostId(String id) async {
    const String query = """
    query(
      \$where: VideoWhereUniqueInput!
    ) {
      video(
        where: \$where
      ) {
        youtubeUrl
      }
    }
    """;

    final Map<String, dynamic> variables = {
      "where": {"id": id}
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

    String? youtubeId;
    try {
      youtubeId =
          VideoId.parseVideoId(jsonResponse['data']['video']['youtubeUrl']);
    } catch (e) {
      throw FormatException(e.toString());
    }
    return youtubeId ?? '';
  }

  Future<List<LiveCamItem>> fetchLiveIdByPostCategory(String category) async {
    const String query = """
    query(
      \$where: VideoWhereInput!
    ) {
      videos(
        where: \$where
        orderBy: [{ publishTime: desc }]
      ) {
        youtubeUrl
      }
    }
    """;

    final Map<String, dynamic> variables = {
      "where": {
        "categories": {
          "some": {
            "slug": {"in": [category]}
          }
        }
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

    final List<String> youtubeIdList = [];
    final List<LiveCamItem> liveCamList = [];

    try {
      if (jsonResponse['data']['videos'] != null) {
        jsonResponse['data']['videos'].forEach((video) {
          if (video['youtubeUrl'] != null) {
            final String? youtubeId = VideoId.parseVideoId(video['youtubeUrl']);
            if (youtubeId != null) youtubeIdList.add(youtubeId);
          }
        });

        final YoutubeExplode yt = YoutubeExplode();
        for (final item in youtubeIdList) {
          final Video video = await yt.videos.get(item);
          String videoUrl;

          if (video.isLive) {
            videoUrl =
            await yt.videos.streamsClient.getHttpLiveStreamUrl(VideoId(item));
          } else {
            final manifest = await yt.videos.streamsClient.getManifest(item);
            final streamInfo = manifest.muxed.sortByVideoQuality().first;
            videoUrl = streamInfo.url.toString();
          }

          final response = await http.get(Uri.parse(videoUrl));
          if (response.statusCode == 200) {
            liveCamList.add(LiveCamItem(youtubeId: item, isLive: video.isLive));
          }
        }
        yt.close();
      }
    } catch (e) {
      throw FormatException(e.toString());
    }

    return liveCamList;
  }
}