import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/category.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/services/editorChoiceService.dart';
import 'package:tv/services/tabStoryListService.dart';

class NewsStoryListController extends GetxController {
  NewsStoryListController({
    required this.categorySlug,
    required this.needCarousel,
    required this.isPopular,
    required this.tabStoryListService,
    required this.editorChoiceService,
  });

  final String categorySlug;
  final bool needCarousel;
  final bool isPopular;
  final TabStoryListServices tabStoryListService;
  final EditorChoiceServices editorChoiceService;

  final RxList<StoryListItem> storyList = <StoryListItem>[].obs;
  final RxList<StoryListItem> editorChoiceList = <StoryListItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isAllLoaded = false.obs;
  final Rxn<MNewException> error = Rxn<MNewException>();
  final RxnString loadMoreErrorMessage = RxnString();

  int allStoryCount = 0;

  @override
  void onInit() {
    super.onInit();
    fetchInitial();
  }

  Future<void> fetchInitial() async {
    isLoading.value = true;
    error.value = null;

    try {
      final result = await _fetchInitialStories();
      storyList.assignAll(result);
      allStoryCount = tabStoryListService.allStoryCount;
      isAllLoaded.value = allStoryCount > 0 && storyList.length >= allStoryCount;

      if (needCarousel) {
        final editorChoices = await editorChoiceService.fetchEditorChoiceList();
        editorChoiceList.assignAll(editorChoices);
      }
    } catch (e) {
      error.value = determineException(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNextPage() async {
    if (isPopular || isLoading.value || isLoadingMore.value || isAllLoaded.value) {
      return;
    }

    isLoadingMore.value = true;
    try {
      final currentLength = storyList.length;
      final newStories = Category.checkIsLatestCategoryBySlug(categorySlug)
          ? await tabStoryListService.fetchStoryList(
              skip: currentLength,
              first: currentLength + 20,
            )
          : await tabStoryListService.fetchStoryListByCategorySlug(
              categorySlug,
              skip: currentLength,
              first: currentLength + 20,
            );

      final existingIds = storyList.map((item) => item.id).toSet();
      final dedupedStories =
          newStories.where((item) => !existingIds.contains(item.id)).toList();
      storyList.addAll(dedupedStories);

      allStoryCount = tabStoryListService.allStoryCount;
      isAllLoaded.value = allStoryCount > 0 && storyList.length >= allStoryCount;
    } catch (_) {
      loadMoreErrorMessage.value = '加載失敗';
    } finally {
      isLoadingMore.value = false;
    }
  }

  void clearLoadMoreErrorMessage() {
    loadMoreErrorMessage.value = null;
  }

  Future<List<StoryListItem>> _fetchInitialStories() {
    if (isPopular) {
      return tabStoryListService.fetchPopularStoryList();
    }

    if (Category.checkIsLatestCategoryBySlug(categorySlug)) {
      return tabStoryListService.fetchStoryList();
    }

    return tabStoryListService.fetchStoryListByCategorySlug(categorySlug);
  }
}
