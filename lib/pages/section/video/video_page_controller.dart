import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/models/category.dart';
import 'package:tv/pages/section/video/videoTabContent.dart';
import 'package:tv/pages/section/video/video_tab_controller.dart';
import 'package:tv/provider/articles_api_provider.dart';

class VideoPageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ArticlesApiProvider _articlesApiProvider = Get.find();
  final TextScaleFactorController textScaleFactorController = Get.find();
  final RxList<Category> rxCategoryList = RxList();
  final RxList<VideoTabContent> rxVideoTabContent = RxList();
  final RxBool rxIsLoadingFinish = false.obs;
  TabController? tabController;

  @override
  void onInit() async {
    super.onInit();

    rxCategoryList.value =
        await _articlesApiProvider.getVideoPageCategoryList();

    rxVideoTabContent.value = rxCategoryList.map((category) {
      Get.delete<VideoTabController>(tag: category.slug);
      Get.lazyPut(() => VideoTabController(category.slug!), tag: category.slug);
      return VideoTabContent(
          categorySlug: category.slug!,
          isFeaturedSlug: category.isFeaturedCategory());
    }).toList();
    tabController = TabController(length: rxCategoryList.length, vsync: this);
    rxIsLoadingFinish.value = true;
  }


}
