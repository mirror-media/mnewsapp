import 'dart:convert';

import 'package:tv/baseConfig.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/storyListItemList.dart';

abstract class TabStoryListRepos {
  void reduceSkip(int reducedNumber);
  Future<StoryListItemList> fetchStoryList({bool withCount = true});
  Future<StoryListItemList> fetchNextPage({int loadingMorePage = 20});
  Future<StoryListItemList> fetchStoryListByCategorySlug(String slug);
  Future<StoryListItemList> fetchNextPageByCategorySlug(String slug, {int loadingMorePage = 20});
  Future<StoryListItemList> fetchPopularStoryList();
}

class TabStoryListServices implements TabStoryListRepos{
  ApiBaseHelper _helper = ApiBaseHelper();
  String? postStyle;
  int skip = 0, first = 20;
  final String query = 
  """
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
    this.first = first;
  }

  @override
  void reduceSkip(int reducedNumber) {
    skip = skip - reducedNumber;
  }

  @override
  Future<StoryListItemList> fetchStoryList({bool withCount = true}) async {
    String key = 'fetchStoryList?skip=$skip&first=$first';
    if(postStyle != null) {
      key = key + '&postStyle=$postStyle';
    }

    Map<String, dynamic> variables = {
      "where": {
        "state": "published",
        "style_not_in": ["wide", "projects", "script", "campaign", "readr"],
      },
      "skip": skip,
      "first": first,
      'withCount': withCount,
    };

    if(postStyle != null) {
      variables["where"].addAll({"style": postStyle});
    }

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final jsonResponse;
    if(skip > 40) {
      jsonResponse = await _helper.postByUrl(
        baseConfig!.graphqlApi,
        jsonEncode(graphqlBody.toJson()),
        headers: {
          "Content-Type": "application/json"
        }
      );
    } else {
      jsonResponse = await _helper.postByCacheAndAutoCache(
        key,
        baseConfig!.graphqlApi,
        jsonEncode(graphqlBody.toJson()),
        maxAge: newsTabStoryList,
        headers: {
          "Content-Type": "application/json"
        }
      );
    }

    StoryListItemList newsList = StoryListItemList.fromJson(jsonResponse['data']['allPosts']);
    if(withCount) {
      newsList.allStoryCount = jsonResponse['data']['_allPostsMeta']['count'];
    }

    return newsList;
  }

  @override
  Future<StoryListItemList> fetchNextPage({int loadingMorePage = 20}) async{
    skip = skip + first;
    first = loadingMorePage;
    return await fetchStoryList();
  }

  @override
  Future<StoryListItemList> fetchStoryListByCategorySlug(String slug, {bool withCount = true}) async {
    String key = 'fetchStoryListByCategorySlug?slug=$slug&skip=$skip&first=$first';
    if(postStyle != null) {
      key = key + '&postStyle=$postStyle';
    }

    Map<String, dynamic> variables = {
      "where": {
        "state": "published",
        "style_not_in": ["wide", "projects", "script", "campaign", "readr"],
        "categories_some": {
          "slug": slug
        },
      },
      "skip": skip,
      "first": first,
      'withCount': withCount,
    };

    if(postStyle != null) {
      variables["where"].addAll({"style": postStyle!});
    }
    
    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final jsonResponse;
    if(skip > 40) {
      jsonResponse = await _helper.postByUrl(
        baseConfig!.graphqlApi,
        jsonEncode(graphqlBody.toJson()),
        headers: {
          "Content-Type": "application/json"
        }
      );
    } else {
      jsonResponse = await _helper.postByCacheAndAutoCache(
        key,
        baseConfig!.graphqlApi,
        jsonEncode(graphqlBody.toJson()),
        maxAge: newsTabStoryList,
        headers: {
          "Content-Type": "application/json"
        }
      );
    }

    StoryListItemList newsList = StoryListItemList.fromJson(jsonResponse['data']['allPosts']);
    if(withCount) {
      newsList.allStoryCount = jsonResponse['data']['_allPostsMeta']['count'];
    }

    return newsList;
  }

  @override
  Future<StoryListItemList> fetchNextPageByCategorySlug(String slug, {int loadingMorePage = 20}) async{
    skip = skip + first;
    first = loadingMorePage;
    return await fetchStoryListByCategorySlug(slug);
  }

  @override
  Future<StoryListItemList> fetchPopularStoryList() async{
    String jsonUrl;
    if(postStyle == 'videoNews') {
      jsonUrl = baseConfig!.videoPopularListUrl;
    } else {
      jsonUrl = baseConfig!.newsPopularListUrl;
    }

    final jsonResponse = await _helper.getByUrl(jsonUrl);
    StoryListItemList storyListItemList = StoryListItemList.fromJson(jsonResponse['report']);
    return storyListItemList;
  }
}
