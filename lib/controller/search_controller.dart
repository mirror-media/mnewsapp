import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/services/searchService.dart';

class SearchController extends GetxController {
  SearchController({required this.searchRepos});

  final SearchRepos searchRepos;

  final RxList<StoryListItem> storyListItemList = <StoryListItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final Rxn<MNewException> error = Rxn<MNewException>();
  final RxString orderBy = 'relevance'.obs;
  final RxString keyword = ''.obs;
  final RxInt allStoryCount = 0.obs;

  bool get hasKeyword => keyword.value.trim().isNotEmpty;
  bool get hasError => error.value != null;
  bool get isInitState =>
      !isLoading.value &&
      !isLoadingMore.value &&
      !hasError &&
      storyListItemList.isEmpty &&
      !hasKeyword;
  bool get isLoadingMax => storyListItemList.length >= allStoryCount.value;

  Future<void> searchNewsStoryByKeyword(String nextKeyword) async {
    final trimmedKeyword = nextKeyword.trim();
    if (trimmedKeyword.isEmpty) {
      clearKeyword();
      return;
    }

    keyword.value = trimmedKeyword;
    error.value = null;
    isLoading.value = true;

    try {
      final results = await searchRepos.searchNewsStoryByKeyword(
        trimmedKeyword,
        orderBy: orderBy.value,
      );

      storyListItemList.assignAll(results);
      allStoryCount.value = searchRepos.allStoryCount;
    } catch (e) {
      error.value = determineException(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchNextPage() async {
    if (!hasKeyword || isLoading.value || isLoadingMore.value || isLoadingMax) {
      return;
    }

    error.value = null;
    isLoadingMore.value = true;

    try {
      final results = await searchRepos.searchNextPageByKeyword(
        keyword.value,
        orderBy: orderBy.value,
      );

      storyListItemList.addAll(results);
      allStoryCount.value = searchRepos.allStoryCount;
    } catch (e) {
      error.value = determineException(e);
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> changeOrderBy(String nextOrderBy) async {
    if (orderBy.value == nextOrderBy) return;

    orderBy.value = nextOrderBy;

    if (hasKeyword) {
      await searchNewsStoryByKeyword(keyword.value);
    }
  }

  void clearKeyword() {
    keyword.value = '';
    error.value = null;
    allStoryCount.value = 0;
    isLoading.value = false;
    isLoadingMore.value = false;
    storyListItemList.clear();
  }
}
