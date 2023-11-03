import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:tv/core/enum/page_status.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/provider/articles_api_provider.dart';

class VideoTabController extends GetxController {
  final ArticlesApiProvider _articlesApiProvider = Get.find();
  ScrollController scrollController = ScrollController(keepScrollOffset: true);
  final RxString rxSlug = ''.obs;
  final RxList<StoryListItem> rxStoryList = RxList();
  final Rx<PageStatus> rxPageStatus = Rx(PageStatus.loading);
  int page = 0;

  VideoTabController(String slug) {
    rxSlug.value = slug;
  }

  @override
  void onInit() async {
    super.onInit();
    scrollController.addListener(scrollEvent);
    rxStoryList.value =
        await _articlesApiProvider.getVideoPostsList(slug: rxSlug.value);
    rxPageStatus.value = PageStatus.normal;
  }

  void scrollEvent() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      loadMorePost();
    }
  }

  void loadMorePost() async {
    if (rxPageStatus.value == PageStatus.loadingEnd) return;
    rxPageStatus.value = PageStatus.loading;
    page++;
    final List<StoryListItem> newPostList = await _articlesApiProvider
        .getVideoPostsList(slug: rxSlug.value, skip: page * 20);
    if (newPostList.isEmpty || newPostList.length < 20) {
      rxPageStatus.value = PageStatus.loadingEnd;
      displayToast('已經載入所有文章');
    }
    rxStoryList.addAll(newPostList);
    rxPageStatus.value = PageStatus.normal;
  }

  void displayToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
