import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/controller/interstitialAdController.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:tv/models/youtube_list_info.dart';
import 'package:tv/pages/section/show/election_widget/election_controller.dart';
import 'package:tv/provider/articles_api_provider.dart';

class ElectionShowStoryController extends GetxController {
  YoutubePlaylistItem? currentPlayListItem;
  String? tag;
  Worker? renderListWorker;
  ElectionController? electionController;
  final interstitialAdController = Get.find<InterstitialAdController>();
  final RxList<YoutubePlaylistItem> rxRenderYoutubeList = RxList();
  final ArticlesApiProvider articlesApiProvider = Get.find();
  final Rxn<YoutubeListInfo> rxPlayListInfo = Rxn();
  ScrollController scrollController = ScrollController(keepScrollOffset: true);
  int playListPage = 1;
  int defaultPlayListOnePageCount = 5;
  bool isShort = false;

  void setYoutubeInfo(
      String? _tag, YoutubePlaylistItem? _youtubePlaylistItem) async {
    if (_tag == null || _youtubePlaylistItem == null) return;
    tag = _tag;
    currentPlayListItem = _youtubePlaylistItem;
    electionController = Get.find<ElectionController>(tag: tag);
    AnalyticsHelper.sendScreenView(
        screenName: 'ShowStoryPage title=${_youtubePlaylistItem.name}');
    if (electionController == null) return;
    isShort = electionController!.rxSegmentedControlValue.value == 1;
    fetchMorePlayList();
    scrollController.addListener(scrollEvent);
  }

  void fetchMorePlayList() async {
    if (electionController == null) return;
    final playListId = isShort
        ? electionController!.rxnShowIntro.value?.playList02?.youtubePlayListId
        : electionController!.rxnShowIntro.value?.playList01?.youtubePlayListId;
    if (playListId == null) {
      return;
    }
    final newInfo = await articlesApiProvider.getYoutubePlayList(
        playListId: playListId,
        maxResult: playListPage * defaultPlayListOnePageCount,
        nextPageToken: electionController!.rxPlayListInfo.value?.nextPageToken);

    if (newInfo.playList?.length == rxRenderYoutubeList.length) {
      return;
    }
    List<YoutubePlaylistItem> resultList = List.from(rxRenderYoutubeList);
    resultList.addAll(newInfo.playList ?? []);
    resultList.removeWhere((element) =>
        element.name == 'Private video' || element == currentPlayListItem);
    rxRenderYoutubeList.value = resultList.toSet().toList();
    rxPlayListInfo.value = newInfo;
  }

  void scrollEvent() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        electionController != null) {
      playListPage++;
      fetchMorePlayList();
    }
  }

  @override
  void dispose() {
    super.dispose();
    renderListWorker?.dispose();
  }
}
