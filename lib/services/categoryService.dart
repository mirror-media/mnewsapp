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

  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<List<Category>> fetchCategoryList() async {
    final jsonResponse = await _helper.getByCacheAndAutoCache(
        Environment().config.categoriesUrl,
        maxAge: categoryCacheDuration,
        headers: {"Accept": "application/json"});

    List<Category> categoryList = List<Category>.from(
        jsonResponse['allCategories']
            .map((category) => Category.fromJson(category)));

    /// cuz video page is in the home drawer sections
    categoryList.removeWhere((category) => category.slug == 'video');

    /// do not display home slug in app
    categoryList.removeWhere((category) => category.slug == 'home');

    String menuJsonPath = isVideo ? videoMenuJson : menuJson;
    String jsonFixed = await rootBundle.loadString(menuJsonPath);
    final fixedMenu = json.decode(jsonFixed);
    List<Category> fixedCategoryList = List<Category>.from(
        fixedMenu.map((category) => Category.fromJson(category)));

    fixedCategoryList.addAll(categoryList);

    return fixedCategoryList;
  }
}
