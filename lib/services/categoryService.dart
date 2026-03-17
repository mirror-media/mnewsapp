import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/category.dart';

abstract class CategoryRepos {
  Future<List<Category>> fetchCategoryList();
}

class CategoryServices implements CategoryRepos {
  final bool isVideo;
  CategoryServices({this.isVideo = false});

  final ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<List<Category>> fetchCategoryList() async {
    final jsonResponse = await _helper.getByCacheAndAutoCache(
      Environment().config.categoriesUrl,
      maxAge: categoryCacheDuration,
      headers: {"Accept": "application/json"},
    );

    const encoder = JsonEncoder.withIndent('  ');
    print("===== categories API JSON =====");
    print(encoder.convert(jsonResponse));
    print("===== categories API JSON runtimeType =====");
    print(jsonResponse.runtimeType);

    List<dynamic> rawCategoryList = [];

    if (jsonResponse is List) {
      rawCategoryList = jsonResponse;
    } else if (jsonResponse is Map<String, dynamic>) {
      if (jsonResponse['allCategories'] is List) {
        rawCategoryList = jsonResponse['allCategories'];
      } else if (jsonResponse['featuredCategories'] is List) {
        rawCategoryList = jsonResponse['featuredCategories'];
      } else if (jsonResponse['categories'] is List) {
        rawCategoryList = jsonResponse['categories'];
      } else {
        throw Exception(
          'Invalid category response format: cannot find category list key.',
        );
      }
    } else {
      throw Exception(
        'Invalid category response type: ${jsonResponse.runtimeType}',
      );
    }

    List<Category> categoryList = List<Category>.from(
      rawCategoryList.map((category) => Category.fromJson(category)),
    );

    /// cuz video page is in the home drawer sections
    categoryList.removeWhere((category) => category.slug == 'video');

    /// do not display home slug in app
    categoryList.removeWhere((category) => category.slug == 'home');

    String menuJsonPath = isVideo ? videoMenuJson : menuJson;
    String jsonFixed = await rootBundle.loadString(menuJsonPath);
    final fixedMenu = json.decode(jsonFixed);

    print("===== local menu JSON =====");
    print(encoder.convert(fixedMenu));

    List<Category> fixedCategoryList = List<Category>.from(
      fixedMenu.map((category) => Category.fromJson(category)),
    );

    fixedCategoryList.addAll(categoryList);

    return fixedCategoryList;
  }
}