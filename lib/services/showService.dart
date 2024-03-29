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
  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<List<Category>> fetchCategoryList() async {
    final jsonResponse = await _helper.getByCacheAndAutoCache(
        Environment().config.categoriesUrl,
        maxAge: categoryCacheDuration,
        headers: {"Accept": "application/json"});

    List<Category> categoryList = List<Category>.from(jsonResponse['allShows']
        .map((category) => Category.fromJson(category)));

    return categoryList;
  }

  @override
  Future<ShowIntro> fetchShowIntroById(String id) async {
    final key = 'fetchShowIntroById?id=$id';

    String query = """
    query (
      \$where: ShowWhereUniqueInput!,
    ) {
      Show(
        where: \$where,
      ) {
        name
        introduction
        picture {
          urlMobileSized
        }
        playList01
        playList02
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

    final jsonResponse = await _helper.postByCacheAndAutoCache(
        key, Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
        maxAge: showIntroCacheDuration,
        headers: {"Content-Type": "application/json"});

    ShowIntro showIntro = ShowIntro.fromJson(jsonResponse['data']['Show']);
    return showIntro;
  }
}
