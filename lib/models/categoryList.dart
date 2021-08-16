import 'dart:convert';

import 'package:tv/models/category.dart';
import 'package:tv/models/customizedList.dart';

class CategoryList extends CustomizedList<Category> {
  static CategoryList _instance = new CategoryList();

  // constructor
  CategoryList();

  factory CategoryList.fromJson(List<dynamic> parsedJson) {
    CategoryList categories = CategoryList();
    List parseList = parsedJson.map((i) => Category.fromJson(i)).toList();
    parseList.forEach((element) {
      categories.add(element);
    });

    _instance = categories;
    return categories;
  }

  factory CategoryList.parseResponseBody(String body) {
    final jsonData = json.decode(body);

    return CategoryList.fromJson(jsonData);
  }

  factory CategoryList.get(){
    return _instance;
  }

  // your custom methods
  List<Map<dynamic, dynamic>> toJson() {
    List<Map> categoryMaps = List.empty(growable: true);

    for (Category category in this) {
      categoryMaps.add(category.toJson());
    }
    return categoryMaps;
  }
}
