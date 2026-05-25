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

  static const int _pageSize = 10;

  // 內部 posts 與外部 externals 各自的分頁游標 / 是否已載完。
  // 兩個來源是獨立集合，必須各自記錄進度。
  int _postsSkip = 0;
  int _externalsSkip = 0;
  bool _postsExhausted = false;
  bool _externalsExhausted = false;

  bool get isInitState =>
      !isLoading.value &&
      !isLoadingMore.value &&
      error.value == null &&
      tagStoryList.isEmpty;

  bool get isAllLoaded => _postsExhausted && _externalsExhausted;

  @override
  void onInit() {
    super.onInit();
    fetchStoryListByTagSlug();
  }

  Future<void> fetchStoryListByTagSlug() async {
    isLoading.value = true;
    error.value = null;
    _postsSkip = 0;
    _externalsSkip = 0;
    _postsExhausted = false;
    _externalsExhausted = false;

    try {
      final result = await tagStoryListRepos.fetchStoryListByTagSlug(
        tagSlug,
        first: _pageSize,
        withCount: true,
      );

      _postsSkip = result.posts.length;
      _externalsSkip = result.externals.length;
      _postsExhausted = result.posts.length < _pageSize;
      _externalsExhausted = result.externals.length < _pageSize;
      allStoryCount.value = result.postsCount + result.externalsCount;

      tagStoryList.assignAll(
        _mergeSorted([...result.posts, ...result.externals]),
      );
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
      final bool needPosts = !_postsExhausted;
      final bool needExternals = !_externalsExhausted;

      final result = await tagStoryListRepos.fetchStoryListByTagSlug(
        tagSlug,
        postsSkip: _postsSkip,
        externalsSkip: _externalsSkip,
        first: _pageSize,
        withCount: false,
        fetchPosts: needPosts,
        fetchExternals: needExternals,
      );

      if (needPosts) {
        _postsSkip += result.posts.length;
        if (result.posts.length < _pageSize) _postsExhausted = true;
      }
      if (needExternals) {
        _externalsSkip += result.externals.length;
        if (result.externals.length < _pageSize) _externalsExhausted = true;
      }

      tagStoryList.assignAll(
        _mergeSorted([
          ...tagStoryList,
          ...result.posts,
          ...result.externals,
        ]),
      );
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

  /// 以 slug/id 去重，再依發佈時間（新 → 舊）排序。
  /// 每次載入後都重排整份清單，確保 posts 與 externals 交錯後順序正確。
  List<StoryListItem> _mergeSorted(List<StoryListItem> items) {
    final seen = <String>{};
    final result = <StoryListItem>[];
    for (final item in items) {
      final key = item.slug ?? item.id ?? item.url ?? '';
      if (key.isEmpty || seen.add(key)) {
        result.add(item);
      }
    }
    result.sort((a, b) => _publishedAt(b).compareTo(_publishedAt(a)));
    return result;
  }

  DateTime _publishedAt(StoryListItem item) {
    final raw = item.publishTime ?? item.updatedAt;
    return DateTime.tryParse(raw ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }
}
