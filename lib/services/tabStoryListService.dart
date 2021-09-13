import 'dart:convert';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/baseConfig.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/models/categoryList.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/models/storyListItemList.dart';

abstract class TabStoryListRepos {
  void reduceSkip(int reducedNumber);
  Future<StoryListItemList> fetchStoryList({bool withCount = true});
  Future<StoryListItemList> fetchNextPage({int loadingMorePage = 20});
  Future<StoryListItemList> fetchStoryListByCategorySlug(String slug);
  Future<StoryListItemList> fetchNextPageByCategorySlug(String slug,
      {int loadingMorePage = 20});
  Future<StoryListItemList> fetchPopularStoryList();
}

class TabStoryListServices implements TabStoryListRepos {
  ApiBaseHelper _helper = ApiBaseHelper();
  String? postStyle;
  int skip = 0, first = 20;
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
    this.first = first;
  }

  @override
  void reduceSkip(int reducedNumber) {
    skip = skip - reducedNumber;
  }

  @override
  Future<StoryListItemList> fetchStoryList({bool withCount = true}) async {
    String key = 'fetchStoryList?skip=$skip&first=$first';
    if (postStyle != null) {
      key = key + '&postStyle=$postStyle';
    }

    Map<String, dynamic> variables = {
      "where": {
        "state": "published",
        "style_not_in": ["wide", "projects", "script", "campaign", "readr"],
        "slug_not_in": filteredSlug,
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
          baseConfig!.graphqlApi, jsonEncode(graphqlBody.toJson()),
          headers: {"Content-Type": "application/json"});
    } else {
      jsonResponse = await _helper.postByCacheAndAutoCache(
          key, baseConfig!.graphqlApi, jsonEncode(graphqlBody.toJson()),
          maxAge: newsTabStoryList,
          headers: {"Content-Type": "application/json"});
    }

    StoryListItemList newsList =
        StoryListItemList.fromJson(jsonResponse['data']['allPosts']);
    if (withCount) {
      newsList.allStoryCount = jsonResponse['data']['_allPostsMeta']['count'];
    }

    return newsList;
  }

  @override
  Future<StoryListItemList> fetchNextPage({int loadingMorePage = 20}) async {
    skip = skip + first;
    first = loadingMorePage;
    return await fetchStoryList();
  }

  @override
  Future<StoryListItemList> fetchStoryListByCategorySlug(String slug,
      {bool withCount = true}) async {
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
          baseConfig!.graphqlApi, jsonEncode(graphqlBody.toJson()),
          headers: {"Content-Type": "application/json"});
    } else {
      jsonResponse = await _helper.postByCacheAndAutoCache(
          key, baseConfig!.graphqlApi, jsonEncode(graphqlBody.toJson()),
          maxAge: newsTabStoryList,
          headers: {"Content-Type": "application/json"});
    }

    final jsonResponseFromGCP = await _helper.getByCacheAndAutoCache(
        baseConfig!.categoriesUrl,
        maxAge: categoryCacheDuration,
        headers: {"Accept": "application/json"});

    StoryListItemList newsList =
        StoryListItemList.fromJson(jsonResponse['data']['allPosts']);

    if (withCount) {
      newsList.allStoryCount = jsonResponse['data']['_allPostsMeta']['count'];
    }

    /// Get featured posts from json
    StoryListItemList newsListFromGCP =
        StoryListItemList.fromJson(jsonResponseFromGCP['allPosts']);
    final jsonResponseGCP = await _helper.getByCacheAndAutoCache(
        baseConfig!.categoriesUrl,
        maxAge: categoryCacheDuration,
        headers: {"Accept": "application/json"});

    CategoryList _categoryList =
        CategoryList.fromJson(jsonResponseGCP['allCategories']);
    String? _categoryId =
        _categoryList.firstWhere((element) => element.slug == slug).id;

    // Find the featured post which category id is equal to the current id
    StoryListItem? _featuredStory;
    for (int i = 0; i < newsListFromGCP.length; i++) {
      if (newsListFromGCP[i].categoryList != null) {
        for (int j = 0; j < newsListFromGCP[i].categoryList!.length; j++) {
          if (newsListFromGCP[i].categoryList![j].id == _categoryId) {
            _featuredStory = newsListFromGCP[i];
            break;
          }
        }
      }
      if (_featuredStory != null) break;
    }

    if (_featuredStory != null) {
      // Remove featured post from the list which get from CMS
      newsList.removeWhere(
          (storyListItem) => storyListItem.id == _featuredStory!.id);
      // Put featured post at the top of the list
      if (skip == 0) newsList.insert(0, _featuredStory);
    }

    return newsList;
  }

  @override
  Future<StoryListItemList> fetchNextPageByCategorySlug(String slug,
      {int loadingMorePage = 20}) async {
    skip = skip + first;
    first = loadingMorePage;
    return await fetchStoryListByCategorySlug(slug);
  }

  @override
  Future<StoryListItemList> fetchPopularStoryList() async {
    String jsonUrl;
    if (postStyle == 'videoNews') {
      jsonUrl = baseConfig!.videoPopularListUrl;
    } else {
      jsonUrl = baseConfig!.newsPopularListUrl;
    }

    final jsonResponse = await _helper.getByUrl(jsonUrl);
    StoryListItemList storyListItemList =
        StoryListItemList.fromJson(jsonResponse['report']);
    return storyListItemList;
  }
}
