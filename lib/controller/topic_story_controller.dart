import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/models/topicStoryList.dart';
import 'package:tv/services/topicService.dart';

class TopicStoryController extends GetxController {
  TopicStoryController({
    required this.topicSlug,
    required this.topicService,
  });

  final String topicSlug;
  final TopicService topicService;

  final Rxn<TopicStoryList> topicStoryList = Rxn<TopicStoryList>();
  final RxList<StoryListItem> storyListItemList = <StoryListItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isAllLoaded = false.obs;
  final Rxn<MNewException> error = Rxn<MNewException>();

  @override
  void onInit() {
    super.onInit();
    fetchTopicStoryList();
  }

  Future<void> fetchTopicStoryList() async {
    isLoading.value = true;
    error.value = null;

    try {
      final topicData = await topicService.fetchTopicStoryList(topicSlug);
      topicStoryList.value = topicData;
      storyListItemList.assignAll(topicData.storyListItemList ?? []);
      isAllLoaded.value = storyListItemList.length == topicData.allStoryCount;
    } catch (e) {
      error.value = determineException(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTopicStoryListMore() async {
    if (isAllLoaded.value ||
        isLoading.value ||
        isLoadingMore.value ||
        topicStoryList.value == null) {
      return;
    }

    isLoadingMore.value = true;

    try {
      final current = topicStoryList.value!;
      final newTopicStoryList = await topicService.fetchTopicStoryList(
        topicSlug,
        skip: current.storyListItemList?.length ?? 0,
        first: 8,
        withCount: false,
      );

      final newStories = newTopicStoryList.storyListItemList ?? [];
      final existingIds = storyListItemList.map((item) => item.id).toSet();
      final dedupedStories =
          newStories.where((item) => !existingIds.contains(item.id)).toList();

      storyListItemList.addAll(dedupedStories);
      topicStoryList.value = TopicStoryList(
        photoUrl: current.photoUrl,
        leading: current.leading,
        storyListItemList: storyListItemList.toList(),
        headerArticles: current.headerArticles,
        headerVideoList: current.headerVideoList,
        headerVideo: current.headerVideo,
        allStoryCount: current.allStoryCount,
      );
      isAllLoaded.value = storyListItemList.length == current.allStoryCount;
    } catch (e) {
      final context = Get.context;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('加載失敗'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      isLoadingMore.value = false;
    }
  }
}
