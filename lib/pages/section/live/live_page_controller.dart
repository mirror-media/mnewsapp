import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:tv/provider/articles_api_provider.dart';
import 'package:tv/services/promotionVideosService.dart';

class LivePageController extends GetxController {
  LivePageController({
    required this.articlesApiProvider,
    required this.promotionVideosRepos,
  });

  final ArticlesApiProvider articlesApiProvider;
  final PromotionVideosRepos promotionVideosRepos;

  final RxnString rxnNewLiveUrl = RxnString();
  final RxList<String> rxLiveCamList = <String>[].obs;
  final RxList<YoutubePlaylistItem> rxPromotionVideoList =
      <YoutubePlaylistItem>[].obs;
  final RxInt selectedPromotionVideoIndex = (-1).obs;
  final RxBool isLoadingLiveStreams = false.obs;
  final RxBool isLoadingPromotionVideos = false.obs;
  final Rxn<MNewException> liveStreamsError = Rxn<MNewException>();
  final Rxn<MNewException> promotionVideosError = Rxn<MNewException>();

  @override
  void onInit() {
    super.onInit();
    fetchLiveStreams();
    fetchPromotionVideos();
  }

  Future<void> fetchLiveStreams() async {
    isLoadingLiveStreams.value = true;
    liveStreamsError.value = null;

    try {
      rxnNewLiveUrl.value = await articlesApiProvider.getNewsLiveUrl();
      rxLiveCamList.assignAll(await articlesApiProvider.getLiveCamUrlList());
    } catch (e) {
      liveStreamsError.value = determineException(e);
    } finally {
      isLoadingLiveStreams.value = false;
    }
  }

  Future<void> fetchPromotionVideos() async {
    isLoadingPromotionVideos.value = true;
    promotionVideosError.value = null;

    try {
      rxPromotionVideoList
          .assignAll(await promotionVideosRepos.fetchAllPromotionVideos());
    } catch (e) {
      promotionVideosError.value = determineException(e);
    } finally {
      isLoadingPromotionVideos.value = false;
    }
  }

  void selectPromotionVideo(int index) {
    selectedPromotionVideoIndex.value = index;
  }
}
