import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/services/ombudsService.dart';

class OmbudsNewsController extends GetxController {
  final OmbudsServiceRepos repository;
  OmbudsNewsController(this.repository);

  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;
  var latestNewsList = <StoryListItem>[].obs;
  var isError = false.obs;
  var error = Rx<MNewException>(Error400Exception(null));

  @override
  void onInit() {
    super.onInit();
    fetchNewsList();
  }

  void fetchNewsList() async {
    await repository.fetchLatestNews().then((value) {
      latestNewsList.assignAll(value);
      hasMore.value = latestNewsList.length < repository.allStoryCount;
      isError.value = false;
    }).catchError((e) {
      isError.value = true;
      error(determineException(e));
      print('OmbudsStoryListError: ${error.value.message}');
    });
    isLoading(false);
  }

  void fetchMoreNews() async {
    isLoadingMore.value = true;
    await repository.fetchLatestNews(skip: latestNewsList.length).then((value) {
      latestNewsList.addAll(value);
      hasMore.value = latestNewsList.length < repository.allStoryCount;
    }).catchError((e) async {
      print('LoadMoreOmbudsStoryListError: $e');
      Fluttertoast.showToast(
        msg: "加載失敗",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      await Future.delayed(const Duration(seconds: 5));
      fetchMoreNews();
    });
  }
}
