import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/controller/interstitialAdController.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:tv/pages/section/show/election_widget/election_controller.dart';

class ElectionShowStoryController extends GetxController {
  YoutubePlaylistItem? currentPlayListItem;
  String? tag;
  Worker? renderListWorker;
  ElectionController? electionController;
  final interstitialAdController = Get.find<InterstitialAdController>();
  final RxList<YoutubePlaylistItem> rxRenderYoutubeList = RxList();
  ScrollController scrollController = ScrollController(keepScrollOffset: true);

  void setYoutubeInfo(
      String? _tag, YoutubePlaylistItem? _youtubePlaylistItem) async {
    if (_tag == null || _youtubePlaylistItem == null) return;
    tag = _tag;
    currentPlayListItem = _youtubePlaylistItem;

    electionController = Get.find<ElectionController>(tag: tag);
    AnalyticsHelper.sendScreenView(
        screenName: 'ShowStoryPage title=${_youtubePlaylistItem.name}');
    if (electionController == null) return;
    rxRenderYoutubeList.clear();
    rxRenderYoutubeList.addAll(
        electionController!.rxSegmentedControlValue.value == 1
            ? electionController!.rxYoutubeShortRenderList
            : electionController!.rxYoutubePlayRenderList);
    rxRenderYoutubeList
        .removeWhere((element) => element == currentPlayListItem);
    renderListWorker = ever<List<YoutubePlaylistItem>>(
        electionController!.rxSegmentedControlValue.value == 1
            ? electionController!.rxYoutubeShortRenderList
            : electionController!.rxYoutubePlayRenderList, (newList) {
      List<YoutubePlaylistItem> resultList = List.from(rxRenderYoutubeList);
      resultList.addAll(newList);

      resultList.removeWhere((element) => element.name == 'Private video');

      rxRenderYoutubeList.value = resultList.toSet().toList();
      rxRenderYoutubeList
          .removeWhere((element) => element == currentPlayListItem);
    });

    scrollController.addListener(scrollEvent);
  }

  void scrollEvent() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        electionController != null) {
      electionController!.getMorePlayList();
    }
  }

  @override
  void dispose() {
    super.dispose();
    renderListWorker?.dispose();
  }
}
