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

    // ✅ Step 1. 自動對應舊分類名稱
    if (slug == 'mirrordaily') {
      print('🔁 Slug "mirrordaily" converted to "external"');
      slug = 'external';
    }

    String key =
        'fetchStoryListByCategorySlug?slug=$slug&skip=$skip&first=$first';
    if (postStyle != null) {
      key = key + '&postStyle=$postStyle';
    }

    // ✅ Step 2. 組 GraphQL 查詢條件
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

    // ✅ Step 3. 送出 GraphQL 請求
    late final jsonResponse;
    if (skip > 40) {
      jsonResponse = await _helper.postByUrl(
          Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
          headers: {"Content-Type": "application/json"});
    } else {
      jsonResponse = await _helper.postByCacheAndAutoCache(
          key,
          Environment().config.graphqlApi,
          jsonEncode(graphqlBody.toJson()),
          maxAge: newsTabStoryList,
          headers: {"Content-Type": "application/json"});
    }

    print('✅ Api post done for slug: $slug');

    // ✅ Step 4. 取得 GraphQL 回傳的文章列表
    List<StoryListItem> newsList = List<StoryListItem>.from(
        jsonResponse['data']['allPosts']
            .map((post) => StoryListItem.fromJson(post)));

    if (withCount && jsonResponse['data']['_allPostsMeta'] != null) {
      allStoryCount = jsonResponse['data']['_allPostsMeta']['count'];
    }

    // ✅ Step 5. 從 GCP featured JSON 抓取推薦文章資料（防呆版本）
    final jsonResponseFromGCP = await _helper.getByCacheAndAutoCache(
        Environment().config.categoriesUrl,
        maxAge: categoryCacheDuration,
        headers: {"Accept": "application/json"});

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

    // ✅ Step 6. 安全查找分類 ID
    final matchedCategory = _categoryList.firstWhere(
          (element) => element.slug == slug,
      orElse: () => Category(id: '', slug: '', name: ''),
    );

    String? _categoryId =
    (matchedCategory.id != null && matchedCategory.id!.isNotEmpty)
        ? matchedCategory.id
        : null;


    print('📘 Available categories: ${_categoryList.map((e) => e.slug).toList()}');
    print('📗 Current slug: $slug, found categoryId: $_categoryId');

    // ✅ Step 7. 找出符合分類的 featured 文章
    StoryListItem? _featuredStory;
    if (_categoryId != null) {
      for (final story in newsListFromGCP) {
        if (story.categoryList != null &&
            story.categoryList!
                .any((category) => category.id == _categoryId)) {
          _featuredStory = story;
          break;
        }
      }
    }

    // ✅ Step 8. 若有 featured 文章，放在第一筆
    if (_featuredStory != null) {
      newsList.removeWhere((item) => item.id == _featuredStory!.id);
      if (skip == 0) newsList.insert(0, _featuredStory);
      print('🌟 Featured story added to top: ${_featuredStory.name}');
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
