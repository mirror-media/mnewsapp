import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final RxBool rxIsESGForumShow = false.obs;
  final Rxn<Map<String, dynamic>> rxEsgForum = Rxn<Map<String, dynamic>>();
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
    await firebaseRemoteConfig.fetchAndActivate();
    rxIsElectionShow.value = firebaseRemoteConfig.getBool('isElectionShow');
    rxIsESGForumShow.value = firebaseRemoteConfig.getBool('isESGForumShow');
    var esgForumJsonString = firebaseRemoteConfig.getString('esgForum');
    if (esgForumJsonString.isNotEmpty) {
      try {
        rxEsgForum.value = jsonDecode(esgForumJsonString);
      } catch (e) {
        print('Error decoding esgForum JSON: $e');
        rxEsgForum.value = {};
      }
    } else {
      rxEsgForum.value = {};
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
