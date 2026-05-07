import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/bindings/news_category_binding.dart';
import 'package:tv/bindings/news_election_binding.dart';
import 'package:tv/controller/news_category_controller.dart';
import 'package:tv/controller/news_election_controller.dart';
import 'package:tv/pages/section/news/news_category_tab.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  void initState() {
    super.initState();
    NewsCategoryBinding().dependencies();
    NewsElectionBinding().dependencies();
  }

  @override
  void dispose() {
    if (Get.isRegistered<NewsCategoryController>()) {
      Get.delete<NewsCategoryController>();
    }
    if (Get.isRegistered<NewsElectionController>()) {
      Get.delete<NewsElectionController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const NewsCategoryTab();
  }
}
