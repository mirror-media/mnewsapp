import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/bindings/search_binding.dart';
import 'package:tv/controller/search_controller.dart' as search;
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/pages/search/search_widget.dart';
import 'package:tv/services/searchService.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
    SearchBinding().dependencies();
    AnalyticsHelper.sendScreenView(screenName: 'SearchPage');
  }

  @override
  void dispose() {
    if (Get.isRegistered<search.SearchController>()) {
      Get.delete<search.SearchController>();
    }
    if (Get.isRegistered<SearchRepos>()) {
      Get.delete<SearchRepos>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: SearchWidget(),
      resizeToAvoidBottomInset: false,
    );
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: Get.back,
      ),
      backgroundColor: appBarColor,
      title: Text('搜尋'),
    );
  }
}
