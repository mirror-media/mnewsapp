import 'dart:convert';

import 'package:tv/models/category.dart';
import 'package:tv/models/customizedList.dart';

class CategoryList extends CustomizedList<Category> {
  // constructor
  CategoryList();

  factory CategoryList.fromJson(List<dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }

    CategoryList categories = CategoryList();
    List parseList = parsedJson.map((i) => Category.fromJson(i)).toList();
    parseList.forEach((element) {
      categories.add(element);
    });

    return categories;
  }

  factory CategoryList.parseResponseBody(String body) {
    final jsonData = json.decode(body);

    return CategoryList.fromJson(jsonData);
  }

  // your custom methods
  List<Map<dynamic, dynamic>> toJson() {
    List<Map> categoryMaps = List.empty(growable: true);
    if (l == null) {
      return null;
    }

    for (Category category in l) {
      categoryMaps.add(category.toJson());
    }
    return categoryMaps;
  }
}
