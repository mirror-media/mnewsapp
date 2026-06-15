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
  Future<List<StoryListItem>> fetchStoryList({
    int skip = 0,
    int first = 20,
    bool withCount = true,
  });
  Future<List<StoryListItem>> fetchStoryListByCategorySlug(
    String slug, {
    int skip = 0,
    int first = 20,
    bool withCount = true,
  });
  Future<List<StoryListItem>> fetchPopularStoryList();
  int allStoryCount = 0;
}

class TabStoryListServices implements TabStoryListRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();
  String? postStyle;

  @override
  int allStoryCount = 0;

  final String query = """
  query (
    \$where: PostWhereInput,
    \$skip: Int,
    \$take: Int,
    \$withCount: Boolean!
  ) {
    posts(
      where: \$where,
      skip: \$skip,
      take: \$take,
      orderBy: [{ publishTime: desc }]
    ) {
      id
      slug
      name
      url
      style

      heroImage {
        imageApiData
        url
        urlMobileSized
        mobile
        w480
        w800
        w1200
        original
        src
      }

      heroVideo {
        coverPhoto {
          imageApiData
          url
          urlMobileSized
          mobile
          w480
          w800
          w1200
          original
          src
        }
      }

      categories: categoriesInInputOrder {
        id
        slug
        name
      }
    }

    postsCount(
      where: \$where
    ) @include(if: \$withCount)
  }
  """;

  TabStoryListServices({String? postStyle, int first = 20}) {
    this.postStyle = postStyle;
  }

  @override
  Future<List<StoryListItem>> fetchStoryList({
    int skip = 0,
    int first = 20,
    bool withCount = true,
  }) async {
    String key = 'fetchStoryList?skip=$skip&first=$first&manualOrder=v1';
    if (postStyle != null) {
      key = '$key&postStyle=$postStyle';
    }

    final List<StoryListItem> editorChoiceList =
        await EditorChoiceServices().fetchEditorChoiceList();

    final List<String> filterSlugList = [];
    filterSlugList.addAll(filteredSlug);
    for (final element in editorChoiceList) {
      if (element.slug != null) filterSlugList.add(element.slug!);
    }

    final Map<String, dynamic> variables = {
      "where": {
        "state": {"equals": "published"},
        "style": {
          "notIn": ["wide", "projects", "script", "campaign", "readr"],
        },
        "slug": {"notIn": filterSlugList},
        "categories": {
          "every": {
            "slug": {
              "notIn": ["ombuds"],
            },
          },
        },
      },
      "skip": skip,
      "take": first,
      "withCount": withCount,
    };

    if (postStyle != null) {
      variables["where"].addAll({
        "style": {"equals": postStyle},
      });
    }

    final GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    if (skip > 40) {
      jsonResponse = await _helper.postByUrl(
        Environment().config.graphqlApi,
        jsonEncode(graphqlBody.toJson()),
        headers: {"Content-Type": "application/json"},
      );
    } else {
      jsonResponse = await _helper.postByCacheAndAutoCache(
        key,
        Environment().config.graphqlApi,
        jsonEncode(graphqlBody.toJson()),
        maxAge: newsTabStoryList,
        headers: {"Content-Type": "application/json"},
      );
    }

    final List<StoryListItem> newsList = List<StoryListItem>.from(
      (jsonResponse['data']['posts'] as List<dynamic>).map(
        (post) => StoryListItem.fromJson(post),
      ),
    );

    if (withCount) {
      allStoryCount = jsonResponse['data']['postsCount'] ?? 0;
    }

    return newsList;
  }

  @override
  Future<List<StoryListItem>> fetchStoryListByCategorySlug(
    String slug, {
    int skip = 0,
    int first = 20,
    bool withCount = true,
  }) async {
    final int take = skip + first;
    const String queryString = """
query FetchCategoryStoryList(
  \$slug: String!,
  \$take: Int!,
  \$withCount: Boolean!
) {
  posts(
    where: {
      state: { equals: "published" }
      style: {
        notIn: ["wide", "projects", "script", "campaign", "readr"]
      }
      categories: {
        some: {
          slug: { equals: \$slug }
        }
      }
    }
    take: \$take
    orderBy: [{ publishTime: desc }]
  ) {
    id
    slug
    name
    style
    publishTime
    heroImage {
      imageApiData
    }
    heroVideo {
      coverPhoto {
        imageApiData
      }
    }
    categories: categoriesInInputOrder {
      id
      slug
      name
    }
  }

  externals(
    where: {
      state: { equals: "published" }
      categories: {
        some: {
          slug: { equals: \$slug }
        }
      }
    }
    take: \$take
    orderBy: [{ publishTime: desc }]
  ) {
    id
    slug
    name
    subtitle
    state
    partner {
      id
      name
      slug
    }
    publishTime
    byline
    thumbnail
    heroCaption
    brief_original
    content_original
    brief
    content
    tags {
      id
      name
      slug
    }
    categories: categoriesInInputOrder {
      id
      name
      slug
    }
    source
    updatedAt
    createdAt
  }

  postsCount(
    where: {
      state: { equals: "published" }
      style: {
        notIn: ["wide", "projects", "script", "campaign", "readr"]
      }
      categories: {
        some: {
          slug: { equals: \$slug }
        }
      }
    }
  ) @include(if: \$withCount)

  externalsCount(
    where: {
      state: { equals: "published" }
      categories: {
        some: {
          slug: { equals: \$slug }
        }
      }
    }
  ) @include(if: \$withCount)
}
""";

    final GraphqlBody graphqlBody = GraphqlBody(
      operationName: 'FetchCategoryStoryList',
      query: queryString,
      variables: {"slug": slug, "take": take, "withCount": withCount},
    );

    final jsonResponse = await _helper.postByUrl(
      Environment().config.graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      headers: {"Content-Type": "application/json"},
    );

    final List<dynamic> postJsonList =
        (jsonResponse['data']?['posts'] as List?) ?? [];
    final List<dynamic> externalJsonList =
        (jsonResponse['data']?['externals'] as List?) ?? [];

    final List<StoryListItem> newsList =
        _mergeSorted([
          ...postJsonList.map((post) => StoryListItem.fromJson(post)),
          ...externalJsonList.map(
            (external) => StoryListItem.fromJson(external),
          ),
        ]).skip(skip).take(first).toList();

    if (withCount) {
      final int postsCount =
          (jsonResponse['data']?['postsCount'] as num?)?.toInt() ?? 0;
      final int externalsCount =
          (jsonResponse['data']?['externalsCount'] as num?)?.toInt() ?? 0;
      allStoryCount = postsCount + externalsCount;
    }

    final jsonResponseFromGCP = await _helper.getByCacheAndAutoCache(
      Environment().config.categoriesUrl,
      maxAge: categoryCacheDuration,
      headers: {"Accept": "application/json"},
    );

    print('[fetchStoryListByCategorySlug] gcp raw = $jsonResponseFromGCP');

    final List<dynamic> allPostsJson =
        (jsonResponseFromGCP['allPosts'] as List?) ?? [];

    final List<StoryListItem> newsListFromGCP =
        allPostsJson.map((post) => StoryListItem.fromJson(post)).toList();

    final List<dynamic> allCategoriesJson =
        (jsonResponseFromGCP['allCategories'] as List?) ?? [];

    final List<Category> categoryList =
        allCategoriesJson
            .map((category) => Category.fromJson(category))
            .toList();

    final matchedCategory = categoryList.firstWhere(
      (element) => element.slug == slug,
      orElse: () => Category(id: '', slug: '', name: ''),
    );

    final String? categoryId =
        (matchedCategory.id != null && matchedCategory.id!.isNotEmpty)
            ? matchedCategory.id
            : null;

    print('Available categories: ${categoryList.map((e) => e.slug).toList()}');
    print('Current slug: $slug, found categoryId: $categoryId');

    StoryListItem? featuredStory;
    if (categoryId != null) {
      for (final story in newsListFromGCP) {
        if (story.categoryList != null &&
            story.categoryList!.any((category) => category.id == categoryId)) {
          featuredStory = story;
          break;
        }
      }
    }

    if (featuredStory != null) {
      newsList.removeWhere(
        (item) =>
            item.id == featuredStory!.id && item.slug == featuredStory.slug,
      );
      if (skip == 0) newsList.insert(0, featuredStory);
      print('Featured story added to top: ${featuredStory.name}');
    }

    return newsList;
  }

  List<StoryListItem> _mergeSorted(Iterable<StoryListItem> items) {
    final seen = <String>{};
    final result = <StoryListItem>[];

    for (final item in items) {
      final key = item.slug ?? item.id ?? item.url ?? '';
      if (key.isEmpty || seen.add(key)) {
        result.add(item);
      }
    }

    result.sort((a, b) => _publishedAt(b).compareTo(_publishedAt(a)));
    return result;
  }

  DateTime _publishedAt(StoryListItem item) {
    final raw = item.publishTime ?? item.updatedAt;
    return DateTime.tryParse(raw ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<List<StoryListItem>> fetchExternalListByPartnerId({
    required String partnerId,
    int skip = 0,
    int first = 20,
  }) async {
    const String externalQuery = """
    query GetAllExternalFields(\$take: Int!, \$skip: Int!, \$partnerId: ID!) {
      externals(
        where: {
          state: { equals: "published" }
          partner: { id: { equals: \$partnerId } }
        }
        skip: \$skip
        take: \$take
        orderBy: [{ publishTime: desc }]
      ) {
        id
        slug
        name
        subtitle
        state
        partner {
          id
          name
          slug
        }
        publishTime
        byline
        thumbnail
        heroCaption
        brief_original
        content_original
        brief
        content
        tags {
          id
          name
          slug
        }
        categories: categoriesInInputOrder {
          id
          name
          slug
        }
        source
        updatedAt
        createdAt
      }
    }
    """;

    final GraphqlBody graphqlBody = GraphqlBody(
      operationName: 'GetAllExternalFields',
      query: externalQuery,
      variables: {"take": first, "skip": skip, "partnerId": partnerId},
    );

    final jsonResponse = await _helper.postByUrl(
      Environment().config.graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      headers: {"Content-Type": "application/json"},
    );

    return List<StoryListItem>.from(
      (jsonResponse['data']['externals'] as List<dynamic>).map(
        (post) => StoryListItem.fromJson(post),
      ),
    );
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
    final List<StoryListItem> storyListItemList = List<StoryListItem>.from(
      (jsonResponse['report'] as List<dynamic>).map(
        (post) => StoryListItem.fromJson(post),
      ),
    );

    return storyListItemList;
  }
}
