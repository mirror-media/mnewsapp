import 'dart:convert';

import 'package:tv/helpers/environment.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/models/category.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/showIntro.dart';
import 'package:tv/services/categoryService.dart';

abstract class ShowRepos {
  Future<ShowIntro> fetchShowIntroById(String id);
}

class ShowServices implements CategoryRepos, ShowRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<List<Category>> fetchCategoryList() async {
    print('===== fetchCategoryList start =====');
    print('===== categoriesUrl =====');
    print(Environment().config.categoriesUrl);

    final jsonResponse = await _helper.getByUrl(
      Environment().config.categoriesUrl,
      headers: {"Accept": "application/json"},
    );

    print('===== ShowServices.fetchCategoryList raw response =====');
    print(jsonResponse);
    print('===== jsonResponse runtimeType =====');
    print(jsonResponse.runtimeType);

    if (jsonResponse is Map) {
      print('===== jsonResponse keys =====');
      print(jsonResponse.keys.toList());
    }

    final List<dynamic> rawList =
        (jsonResponse['shows'] as List?) ??
            (jsonResponse['categories'] as List?) ??
            (jsonResponse['allShows'] as List?) ??
            [];

    print('===== rawList length =====');
    print(rawList.length);

    if (rawList.isNotEmpty) {
      print('===== rawList first item =====');
      print(rawList.first);
      print('===== rawList first item runtimeType =====');
      print(rawList.first.runtimeType);

      if (rawList.first is Map) {
        final firstMap = Map<String, dynamic>.from(rawList.first as Map);
        print('===== rawList first item keys =====');
        print(firstMap.keys.toList());
        print('===== rawList first item contains listShow =====');
        print(firstMap.containsKey('listShow'));
        print('===== rawList first item listShow =====');
        print(firstMap['listShow']);
      }
    }

    final List<Category> categoryList = [];

    for (var item in rawList) {
      print('----- item start -----');
      print(item);
      print('type: ${item.runtimeType}');

      if (item is Map) {
        final map = Map<String, dynamic>.from(item);

        print('slug: ${map['slug']}');
        print('keys: ${map.keys.toList()}');
        print('contains listShow: ${map.containsKey('listShow')}');
        print('listShow: ${map['listShow']}');

        if (map['listShow'] == false) {
          print('✅ PASS (will add into categoryList)');
          final category = Category.fromJson(map);
          categoryList.add(category);

          print('✅ added category: '
              'id=${category.id}, '
              'name=${category.name}, '
              'slug=${category.slug}');
        } else {
          print('❌ FILTERED OUT');
        }
      } else {
        print('❌ NOT A MAP');
      }

      print('----- item end -----');
    }

    print('===== final categoryList length =====');
    print(categoryList.length);

    print('===== final categoryList data =====');
    for (final category in categoryList) {
      print({
        'id': category.id,
        'name': category.name,
        'slug': category.slug,
      });
    }

    print('===== fetchCategoryList end =====');

    return categoryList;
  }

  @override
  Future<ShowIntro> fetchShowIntroById(String id) async {
    final key = 'fetchShowIntroById?id=$id';

    const String query = """
    query (
      \$where: ShowWhereUniqueInput!
    ) {
      show(
        where: \$where
      ) {
        name
        introduction
        picture {
          imageApiData
        }
        playList01
        playList02
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

    final jsonResponse = await _helper.postByCacheAndAutoCache(
      key,
      Environment().config.graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      maxAge: showIntroCacheDuration,
      headers: {"Content-Type": "application/json"},
    );

    final ShowIntro showIntro = ShowIntro.fromJson(jsonResponse['data']['show']);
    return showIntro;
  }
}