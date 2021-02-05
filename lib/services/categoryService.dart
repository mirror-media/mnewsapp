import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/apiConstants.dart';
import 'package:tv/models/categoryList.dart';
import 'package:tv/models/graphqlBody.dart';

abstract class CategoryRepos {
  Future<CategoryList> fetchCategoryList();
}

class CategoryServices implements CategoryRepos{
  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<CategoryList> fetchCategoryList() async {
    String query = 
    """
    query {
      allCategories(sortBy: [sortOrder_ASC]) {
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
      graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      headers: {
        "Content-Type": "application/json"
      }
    );

    CategoryList categoryList = CategoryList.fromJson(jsonResponse['data']['allCategories']);

    String jsonFixed = await rootBundle.loadString('assets/json/menu.json');
    final fixedMenu = json.decode(jsonFixed);
    CategoryList fixedCategoryList = CategoryList.fromJson(fixedMenu);
    fixedCategoryList.addAll(categoryList);
    
    return fixedCategoryList;
  }
}
