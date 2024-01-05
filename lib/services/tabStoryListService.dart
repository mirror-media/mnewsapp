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

    final jsonResponseFromGCP = await _helper.getByCacheAndAutoCache(
        Environment().config.categoriesUrl,
        maxAge: categoryCacheDuration,
        headers: {"Accept": "application/json"});

    List<StoryListItem> newsList = List<StoryListItem>.from(jsonResponse['data']
            ['allPosts']
        .map((post) => StoryListItem.fromJson(post)));

    if (withCount) {
      allStoryCount = jsonResponse['data']['_allPostsMeta']['count'];
    }

    /// Get featured posts from json
    List<StoryListItem> newsListFromGCP = List<StoryListItem>.from(
        jsonResponseFromGCP['allPosts']
            .map((post) => StoryListItem.fromJson(post)));
    final jsonResponseGCP = await _helper.getByCacheAndAutoCache(
        Environment().config.categoriesUrl,
        maxAge: categoryCacheDuration,
        headers: {"Accept": "application/json"});

    List<Category> _categoryList = List<Category>.from(
        jsonResponseGCP['allCategories']
            .map((category) => Category.fromJson(category)));
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
