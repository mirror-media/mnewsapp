import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tv/baseConfig.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/categoryList.dart';
import 'package:tv/models/graphqlBody.dart';

abstract class CategoryRepos {
  Future<CategoryList> fetchCategoryList();
}

class CategoryServices implements CategoryRepos{
  final bool isVideo;
  CategoryServices({this.isVideo = false});

  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<CategoryList> fetchCategoryList() async {
    String query = 
    """
    query {
      allCategories(
        where: {
          isFeatured: true
        },
        sortBy: [sortOrder_ASC]
      ) {
        id
        name
        slug
      }
    }
    """;

    Map<String,String> variables = {};

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
      baseConfig!.graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      headers: {
        "Content-Type": "application/json"
      }
    );

    CategoryList categoryList = CategoryList.fromJson(jsonResponse['data']['allCategories']);

    /// cuz video page is in the home drawer sections
    categoryList.removeWhere((category) => category.slug == 'video');
    /// do not display home slug in app
    categoryList.removeWhere((category) => category.slug == 'home');

    String menuJsonPath = isVideo ? videoMenuJson : menuJson;
    String jsonFixed = await rootBundle.loadString(menuJsonPath);
    final fixedMenu = json.decode(jsonFixed);
    CategoryList fixedCategoryList = CategoryList.fromJson(fixedMenu);
    fixedCategoryList.addAll(categoryList);
    
    return fixedCategoryList;
  }
}
