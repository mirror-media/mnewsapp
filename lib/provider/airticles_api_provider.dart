import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:tv/core/extensions/string_extension.dart';
import 'package:tv/data/value/query.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:tv/helpers/environment.dart';

class ArticlesApiProvider extends GetConnect {
  ArticlesApiProvider._();

  static final ArticlesApiProvider _instance = ArticlesApiProvider._();

  static ArticlesApiProvider get instance => _instance;
  ValueNotifier<GraphQLClient>? client;

  @override
  void onInit() {
    initGraphQLLink();
  }

  void initGraphQLLink() {
    final Link link = HttpLink(Environment().config.graphqlApi);
    client = ValueNotifier(
      GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      ),
    );
  }

  Future<String?> getNewsLiveUrl() async {
    String queryString =
        QueryCommand.getYoutubeStreamList.format(['mnews-live']);
    final result =
        await client?.value.query(QueryOptions(document: gql(queryString)));
    if (result == null ||
        result.data == null ||
        !result.data!.containsKey('allVideos')) return null;
    final videoList = result.data!['allVideos'] as List<dynamic>;
    if (videoList.isEmpty) return null;
    return videoList[0]['youtubeUrl'];
  }

  Future<List<String>> getLiveCamUrlList() async {
    String queryString = QueryCommand.getYoutubeStreamList.format(['live-cam']);
    final result =
        await client?.value.query(QueryOptions(document: gql(queryString)));
    if (result == null ||
        result.data == null ||
        !result.data!.containsKey('allVideos')) return [];
    final videoList = result.data!['allVideos'] as List<dynamic>;
    return videoList.map((video) => video!['youtubeUrl'].toString()).toList();
  }
}
