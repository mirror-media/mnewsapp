import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/controller/initial_app_controller.dart';
import 'package:tv/core/enum/page_status.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/provider/articles_api_provider.dart';
import 'dart:convert';

class NewsPageController extends GetxController {
  ArticlesApiProvider articlesApiProvider = Get.find();
  FirebaseRemoteConfig firebaseRemoteConfig = FirebaseRemoteConfig.instance;
  final RxnString rxnNewLiveUrl = RxnString();
  final RxList rxLiveCamList = RxList();
  final RxBool rxIsElectionShow = false.obs;
  final RxBool rxIsBannerShow = false.obs;
  final RxMap<String, dynamic> rxBannerData = <String, dynamic>{}.obs;
  final RxList<StoryListItem> rxEditorChoiceList = RxList();
  final RxList<StoryListItem> rxRenderStoryList = RxList();
  final List<int> articleInsertIndexArray = [4, 6, 9, 11];
  int page = 0;
  final int articleDefaultCountOnePage = 20;
  ScrollController scrollController = ScrollController(keepScrollOffset: true);
  final Rx<PageStatus> rxPageStatus = PageStatus.loading.obs;

  @override
  void onInit() async {
    super.onInit();
    // InitialAppController 已負責 fetchAndActivate，這裡等它完成再讀值，
    // 避免兩個並行 fetch 造成 firebase_remote_config "cancelled" 例外、
    // 導致 onInit 中斷使 election/banner/liveUrl/editorChoice/文章清單都沒載到。
    await _waitForRemoteConfigReady();
    rxIsElectionShow.value = firebaseRemoteConfig.getBool('isElectionShow');
    rxIsBannerShow.value = firebaseRemoteConfig.getBool('isBannerShow');
    String? bannerJsonString = firebaseRemoteConfig.getString('BannerURL');
    if (bannerJsonString.isNotEmpty) {
      try {
        rxBannerData.assignAll(jsonDecode(bannerJsonString));
      } catch (e) {
        rxBannerData.clear();
      }
    } else {
      rxBannerData.clear();
    }
    rxnNewLiveUrl.value = await articlesApiProvider.getNewsLiveUrl();
    rxLiveCamList.value = await articlesApiProvider.getLiveCamUrlList();
    rxEditorChoiceList.value =
        await articlesApiProvider.fetchEditorChoiceList();
    fetchArticleList();
    scrollController.addListener(scrollEvent);
  }

  void scrollEvent() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      fetchMoreArticle();
    }
  }

  /// 等 InitialAppController 把 remote config fetchAndActivate 完成。
  /// 若 InitialAppController 載入失敗（error 已設），也讓流程繼續，
  /// 後續的 getBool/getString 會落回 setDefaults 設定的預設值。
  Future<void> _waitForRemoteConfigReady() async {
    while (true) {
      if (Get.isRegistered<InitialAppController>()) {
        final InitialAppController controller =
            Get.find<InitialAppController>();
        if (controller.isConfigReady.value) return;
        if (controller.error.value != null) return;
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  void fetchArticleList() async {
    rxPageStatus.value = PageStatus.loading;
    final latestResult = await articlesApiProvider.getLatestArticles();
    rxRenderStoryList.value = latestResult;
    final salesArticles = await articlesApiProvider.getSalesArticles();
    for (int salesArticleIndex = 0;
        salesArticleIndex < salesArticles.length &&
            salesArticleIndex < articleInsertIndexArray.length;
        salesArticleIndex++) {
      rxRenderStoryList.insert(articleInsertIndexArray[salesArticleIndex] - 1,
          salesArticles[salesArticleIndex]);
    }
    rxPageStatus.value = PageStatus.normal;
  }

  void fetchMoreArticle() async {
    rxPageStatus.value = PageStatus.loading;
    page++;
    final newLatestArticle = await articlesApiProvider.getLatestArticles(
        skip: page * 20, first: articleDefaultCountOnePage);
    Set<StoryListItem> uniqueObjects =
        Set<StoryListItem>.from(rxRenderStoryList)..addAll(newLatestArticle);
    rxRenderStoryList.value = uniqueObjects.toList();
    rxPageStatus.value = PageStatus.normal;
  }
}
