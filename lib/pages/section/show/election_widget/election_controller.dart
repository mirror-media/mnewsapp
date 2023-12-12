import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/models/podcast_info/podcast_info.dart';
import 'package:tv/models/showIntro.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:tv/models/youtube_list_info.dart';
import 'package:tv/provider/articles_api_provider.dart';

class ElectionController extends GetxController
    with GetTickerProviderStateMixin {
  final ArticlesApiProvider articlesApiProvider = Get.find();
  final int defaultPlayListOnePageCount = 5;
  late int playListPage = 1;
  late int playListShortPage = 1;
  final TextScaleFactorController textScaleFactorController = Get.find();

  final Rxn<ShowIntro> rxnShowIntro = Rxn();
  final RxList<YoutubePlaylistItem> rxYoutubePlayRenderList = RxList();
  final RxList<YoutubePlaylistItem> rxYoutubeShortRenderList = RxList();
  final Rxn<YoutubeListInfo> rxPlayListInfo = Rxn();
  final Rxn<YoutubeListInfo> rxShortPlayListInfo = Rxn();
  final RxInt rxSegmentedControlValue = 0.obs;
  final RxList<PodcastInfo> rxPodcastInfoList = RxList();
  final Rxn<PodcastInfo> rxnSelectPodcastInfo = Rxn();
  final RxInt rxPodcastDisplayCount = 5.obs;

  late AnimationController animationController;
  late Animation<double> animation;
  late String? tag;

  @override
  void onInit() async {
    super.onInit();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    animation = Tween(begin: -130.0, end: 0.0).animate(animationController);
    rxnShowIntro.value =
        await articlesApiProvider.getShowIntro(slug: tag ?? '');
    fetchYoutubePlayList();
    fetchYoutubeShortPlayList();
    fetchPodcastList();
  }

  ElectionController(String? _tag) {
    tag = _tag;
  }

  void fetchYoutubePlayList() async {
    final playListId = rxnShowIntro.value?.playList01?.youtubePlayListId;
    if (playListId == null) {
      return;
    }
    final newInfo = await articlesApiProvider.getYoutubePlayList(
        playListId: playListId,
        maxResult: defaultPlayListOnePageCount,
        nextPageToken: rxPlayListInfo.value?.nextPageToken);


    List<YoutubePlaylistItem> resultList = List.from(rxYoutubePlayRenderList);
    resultList.addAll(newInfo.playList ?? []);
    resultList.removeWhere((element) => element.name == 'Private video');
    rxYoutubePlayRenderList.value = resultList.toSet().toList();
    rxPlayListInfo.value = newInfo;
  }

  void fetchYoutubeShortPlayList() async {
    final playListId = rxnShowIntro.value?.playList02?.youtubePlayListId;
    if (playListId == null) {
      return;
    }
    final newInfo = await articlesApiProvider.getYoutubePlayList(
        playListId: playListId,
        maxResult: defaultPlayListOnePageCount,
        nextPageToken: rxShortPlayListInfo.value?.nextPageToken);



    List<YoutubePlaylistItem> resultList = List.from(rxYoutubeShortRenderList);
    resultList.addAll(newInfo.playList ?? []);

    resultList.removeWhere((element) => element.name == 'Private video');

    rxYoutubeShortRenderList.value = resultList.toSet().toList();
    rxShortPlayListInfo.value = newInfo;

  }

  void fetchPodcastList() async {
    rxPodcastInfoList.value = await articlesApiProvider.getPodcastInfoList();
  }

  void getMorePlayList() {
    if (rxSegmentedControlValue.value == 0) {
      playListPage++;
      fetchYoutubePlayList();
    } else {
      playListShortPage++;
      fetchYoutubeShortPlayList();
    }
  }

  void getMorePodcast() {
    rxPodcastDisplayCount.value += 5;
    if (rxPodcastDisplayCount.value > rxPodcastInfoList.length) {
      rxPodcastDisplayCount.value = rxPodcastInfoList.length;
      Fluttertoast.showToast(
          msg: "所有Podcast都加載完畢囉",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Get.theme.primaryColor,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void segmentedControlValueChange(int value) {
    rxSegmentedControlValue.value = value;
  }

  void podcastItemClickEvent(PodcastInfo podcastInfo) {
    if (rxnSelectPodcastInfo.value == podcastInfo) {
      return;
    }
    if (rxnSelectPodcastInfo.value == null) {
      animationController.forward();
    }
    rxnSelectPodcastInfo.value = podcastInfo;
  }
}
