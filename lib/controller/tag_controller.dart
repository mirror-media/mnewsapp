import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/services/tagStoryListService.dart';

class TagController extends GetxController {
  TagController({
    required this.tagSlug,
    required this.tagStoryListRepos,
  });

  final String tagSlug;
  final TagStoryListRepos tagStoryListRepos;

  final RxList<StoryListItem> tagStoryList = <StoryListItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final Rxn<MNewException> error = Rxn<MNewException>();
  final RxInt allStoryCount = 0.obs;

  bool get isInitState =>
      !isLoading.value &&
      !isLoadingMore.value &&
      error.value == null &&
      tagStoryList.isEmpty;

  bool get isAllLoaded => tagStoryList.length >= allStoryCount.value;

  @override
  void onInit() {
    super.onInit();
    fetchStoryListByTagSlug();
  }

  Future<void> fetchStoryListByTagSlug() async {
    isLoading.value = true;
    error.value = null;

    try {
      final stories = await tagStoryListRepos.fetchStoryListByTagSlug(tagSlug);
      tagStoryList.assignAll(stories);
      allStoryCount.value = tagStoryListRepos.allStoryCount;
    } catch (e) {
      error.value = determineException(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNextPageByTagSlug() async {
    if (isLoading.value || isLoadingMore.value || isAllLoaded) return;

    isLoadingMore.value = true;

    try {
      final stories = await tagStoryListRepos.fetchStoryListByTagSlug(
        tagSlug,
        skip: tagStoryList.length,
        withCount: false,
      );

      final existingIds = tagStoryList.map((item) => item.id).toSet();
      final newStories = stories.where((item) => !existingIds.contains(item.id));
      tagStoryList.addAll(newStories);
    } catch (e) {
      final snackBar = SnackBar(
        content: const Text('加載失敗'),
        backgroundColor: Colors.red,
      );
      final context = Get.context;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } finally {
      isLoadingMore.value = false;
    }
  }
}
