import 'dart:convert';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/models/category.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/services/editorChoiceService.dart';

abstract class TabStoryListRepos {
  Future<List<StoryListItem>> fetchStoryList(
      {int skip = 0, int first = 20, bool withCount = true});
  Future<List<StoryListItem>> fetchStoryListByCategorySlug(String slug,
      {int skip = 0, int first = 20, bool withCount = true});
  Future<List<StoryListItem>> fetchPopularStoryList();
  int allStoryCount = 0;
}

class TabStoryListServices implements TabStoryListRepos {
  ApiBaseHelper _helper = ApiBaseHelper();
  String? postStyle;

  @override
  int allStoryCount = 0;

  final String query = """
  query (
    \$where: PostWhereInput,
    \$skip: Int,
    \$first: Int,
    \$withCount: Boolean!,
  ) {
    allPosts(
      where: \$where, 
      skip: \$skip, 
      first: \$first, 
      sortBy: [ publishTime_DESC ]
    ) {
      id
      slug
      name
      heroImage {
        urlMobileSized
      }
    }
    _allPostsMeta(
      where: \$where,
    ) @include(if: \$withCount) {
      count
    }
  }
  """;

  TabStoryListServices({String? postStyle, int first = 20}) {
    this.postStyle = postStyle;
  }

  //  新增：抓外部合作媒體（例如鏡報）的資料
  Future<List<StoryListItem>> fetchExternalListByPartnerId(String partnerId, {int first = 20}) async {
    final String query = """
    query GetAllExternalFields(\$first: Int!, \$partnerId: ID!) {
      allExternals(
        where: { state: published, partner: { id: \$partnerId } },
        first: \$first,
        sortBy: updatedAt_DESC
      ) {
        id
        slug
        name
        thumbnail
        partner {
          id
          name
          slug
        }
      }
    }
    """;

    final variables = {
      "first": first,
      "partnerId": partnerId,
    };

    final jsonResponse = await _helper.postByUrl(
      Environment().config.graphqlApi,
      jsonEncode({"query": query, "variables": variables}),
      headers: {"Content-Type": "application/json"},
    );

    if (jsonResponse['data'] == null || jsonResponse['data']['allExternals'] == null) {
      print('️ No externals data returned.');
      return [];
    }

    List<StoryListItem> newsList = List<StoryListItem>.from(
        jsonResponse['data']['allExternals'].map((post) => StoryListItem.fromJson(post))
    );

    print('External partner data fetched: ${newsList.length} items.');
    return newsList;
  }

  @override
  Future<List<StoryListItem>> fetchStoryList(
      {int skip = 0, int first = 20, bool withCount = true}) async {
    String key = 'fetchStoryList?skip=$skip&first=$first';
    if (postStyle != null) {
      key = key + '&postStyle=$postStyle';
    }
    List<StoryListItem> editorChoiceList =
    await EditorChoiceServices().fetchEditorChoiceList();
    List<String> filterSlugList = [];
    filterSlugList.addAll(filteredSlug);
    editorChoiceList.forEach((element) {
      if (element.slug != null) filterSlugList.add(element.slug!);
    });

    Map<String, dynamic> variables = {
      "where": {
        "state": "published",
        "style_not_in": ["wide", "projects", "script", "campaign", "readr"],
        "slug_not_in": filterSlugList,
        "categories_every": {"slug_not_in": "ombuds"},
      },
      "skip": skip,
      "first": first,
      'withCount': withCount,
    };

    if (postStyle != null) {
      variables["where"].addAll({"style": postStyle});
    }

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final jsonResponse;
    if (skip > 40) {
      jsonResponse = await _helper.postByUrl(
          Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
          headers: {"Content-Type": "application/json"});
    } else {
      jsonResponse = await _helper.postByCacheAndAutoCache(key,
          Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
          maxAge: newsTabStoryList,
          headers: {"Content-Type": "application/json"});
    }

    List<StoryListItem> newsList = List<StoryListItem>.from(jsonResponse['data']
    ['allPosts']
        .map((post) => StoryListItem.fromJson(post)));

    if (withCount) {
      allStoryCount = jsonResponse['data']['_allPostsMeta']['count'];
    }

    return newsList;
  }

  @override
  Future<List<StoryListItem>> fetchStoryListByCategorySlug(String slug,
      {int skip = 0, int first = 20, bool withCount = true}) async {

    //特殊處理：鏡報改打 allExternals
    if (slug == 'mirrordaily') {
      print('📰 Fetching external data for Mirror Daily...');
      return await fetchExternalListByPartnerId('2', first: first);
    }

    String key =
        'fetchStoryListByCategorySlug?slug=$slug&skip=$skip&first=$first';
    if (postStyle != null) {
      key = key + '&postStyle=$postStyle';
    }

    Map<String, dynamic> variables = {
      "where": {
        "state": "published",
        "style_not_in": ["wide", "projects", "script", "campaign", "readr"],
        "categories_some": {"slug": slug},
      },
      "skip": skip,
      "first": first,
      'withCount': withCount,
    };

    if (postStyle != null) {
      variables["where"].addAll({"style": postStyle!});
    }

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final jsonResponse;
    if (skip > 40) {
      jsonResponse = await _helper.postByUrl(
          Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
          headers: {"Content-Type": "application/json"});
    } else {
      jsonResponse = await _helper.postByCacheAndAutoCache(key,
          Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
          maxAge: newsTabStoryList,
          headers: {"Content-Type": "application/json"});
    }

    print('✅ Api post done for slug: $slug');

    List<StoryListItem> newsList = List<StoryListItem>.from(
        jsonResponse['data']['allPosts']
            .map((post) => StoryListItem.fromJson(post)));

    if (withCount && jsonResponse['data']['_allPostsMeta'] != null) {
      allStoryCount = jsonResponse['data']['_allPostsMeta']['count'];
    }

    return newsList;
  }

  @override
  Future<List<StoryListItem>> fetchPopularStoryList() async {
    String jsonUrl;
    if (postStyle == 'videoNews') {
      jsonUrl = Environment().config.videoPopularListUrl;
    } else {
      jsonUrl = Environment().config.newsPopularListUrl;
    }

    final jsonResponse = await _helper.getByUrl(jsonUrl);
    List<StoryListItem> storyListItemList = List<StoryListItem>.from(
        jsonResponse['report'].map((post) => StoryListItem.fromJson(post)));

    return storyListItemList;
  }
}
