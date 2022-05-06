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
      youtubeId =
          VideoId.parseVideoId(jsonResponse['data']['Video']['youtubeUrl']);
    } catch (e) {
      throw FormatException(e.toString());
    }
    return youtubeId ?? '';
  }

  Future<List<LiveCamItem>> fetchLiveIdByPostCategory(String category) async {
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
    List<LiveCamItem> liveCamList = [];
    try {
      if (jsonResponse['data']['allVideos'] != null) {
        jsonResponse['data']['allVideos'].forEach((video) {
          if (video['youtubeUrl'] != null) {
            String? youtubeId = VideoId.parseVideoId(video['youtubeUrl']);
            if (youtubeId != null) youtubeIdList.add(youtubeId);
          }
        });

        YoutubeExplode yt = YoutubeExplode();
        for (var item in youtubeIdList) {
          Video video = await yt.videos.get(item);
          String videoUrl;
          if (video.isLive) {
            videoUrl = await yt.videos.streamsClient
                .getHttpLiveStreamUrl(VideoId(item));
          } else {
            var manifest = await yt.videos.streamsClient.getManifest(item);
            var streamInfo = manifest.muxed.sortByVideoQuality().first;
            videoUrl = streamInfo.url.toString();
          }
          final reponse = await http.get(Uri.parse(videoUrl));
          if (reponse.statusCode == 200) {
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
