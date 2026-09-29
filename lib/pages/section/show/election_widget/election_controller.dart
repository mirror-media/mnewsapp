import 'package:get/get.dart';
import 'package:tv/controller/text_scale_factor_controller.dart';
import 'package:tv/models/showIntro.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:tv/models/youtube_list_info.dart';
import 'package:tv/provider/articles_api_provider.dart';

class ElectionController extends GetxController {
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
  late String? tag;

  @override
  void onInit() async {
    super.onInit();
    rxnShowIntro.value = await articlesApiProvider.getShowIntro(
      slug: tag ?? '',
    );
    fetchYoutubePlayList();
    fetchYoutubeShortPlayList();
  }

  ElectionController(String? _tag) {
    tag = _tag;
  }

  void fetchYoutubePlayList() async {
    final playListId =
        rxnShowIntro.value?.playList01?.youtubePlayListId?.trim();

    print('[ElectionController] playList01 id = "$playListId"');

    if (playListId == null || playListId.isEmpty) {
      print('[ElectionController] playList01 is empty, skip request');
      return;
    }

    final newInfo = await articlesApiProvider.getYoutubePlayList(
      playListId: playListId,
      maxResult: defaultPlayListOnePageCount,
      nextPageToken: rxPlayListInfo.value?.nextPageToken,
    );

    List<YoutubePlaylistItem> resultList = List.from(rxYoutubePlayRenderList);
    resultList.addAll(newInfo.playList ?? []);
    resultList.removeWhere((element) => element.name == 'Private video');
    rxYoutubePlayRenderList.value = resultList.toSet().toList();
    rxPlayListInfo.value = newInfo;
  }

  void fetchYoutubeShortPlayList() async {
    final playListId =
        rxnShowIntro.value?.playList02?.youtubePlayListId?.trim();

    print('[ElectionController] playList02 id = "$playListId"');

    if (playListId == null || playListId.isEmpty) {
      print('[ElectionController] playList02 is empty, skip request');
      return;
    }

    final newInfo = await articlesApiProvider.getYoutubePlayList(
      playListId: playListId,
      maxResult: defaultPlayListOnePageCount,
      nextPageToken: rxShortPlayListInfo.value?.nextPageToken,
    );

    List<YoutubePlaylistItem> resultList = List.from(rxYoutubeShortRenderList);
    resultList.addAll(newInfo.playList ?? []);
    resultList.removeWhere((element) => element.name == 'Private video');

    rxYoutubeShortRenderList.value = resultList.toSet().toList();
    rxShortPlayListInfo.value = newInfo;
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

  void segmentedControlValueChange(int value) {
    rxSegmentedControlValue.value = value;
  }
}
