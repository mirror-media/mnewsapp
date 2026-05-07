import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/services/liveService.dart';

class LiveWidgetController extends GetxController {
  LiveWidgetController({
    required this.livePostId,
    required this.liveRepos,
  });

  final String livePostId;
  final LiveRepos liveRepos;

  final RxnString liveId = RxnString();
  final RxBool isLoading = false.obs;
  final Rxn<MNewException> error = Rxn<MNewException>();

  @override
  void onInit() {
    super.onInit();
    fetchLiveId();
  }

  Future<void> fetchLiveId() async {
    isLoading.value = true;
    error.value = null;

    try {
      liveId.value = await liveRepos.fetchLiveIdByPostId(livePostId);
    } catch (e) {
      error.value = determineException(e);
    } finally {
      isLoading.value = false;
    }
  }
}
