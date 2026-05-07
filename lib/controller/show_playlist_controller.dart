import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:tv/services/youtubePlaylistService.dart';

class ShowPlaylistController extends GetxController {
  ShowPlaylistController({
    required this.playlistId,
    required this.maxResults,
    required this.youtubePlaylistService,
  });

  final String playlistId;
  final int maxResults;
  final YoutubePlaylistServices youtubePlaylistService;

  final RxList<YoutubePlaylistItem> youtubePlaylistItemList =
      <YoutubePlaylistItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final Rxn<MNewException> error = Rxn<MNewException>();

  @override
  void onInit() {
    super.onInit();
    fetchInitial();
  }

  Future<void> fetchInitial() async {
    isLoading.value = true;
    error.value = null;

    try {
      final items = await youtubePlaylistService.fetchSnippetByPlaylistId(
        playlistId,
        maxResults: maxResults,
      );
      youtubePlaylistItemList.assignAll(items);
    } catch (e) {
      error.value = determineException(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMore() async {
    if (isLoading.value || isLoadingMore.value) return;

    isLoadingMore.value = true;
    try {
      final items =
          await youtubePlaylistService.fetchSnippetByPlaylistIdAndPageToken(
        playlistId,
        maxResults: maxResults,
      );
      if (items.isNotEmpty) {
        youtubePlaylistItemList.addAll(items);
      }
    } catch (_) {
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
