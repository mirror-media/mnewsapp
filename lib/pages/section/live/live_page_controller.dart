import 'package:get/get.dart';

import '../../../provider/airticles_api_provider.dart';

class LivePageController extends GetxController {
  ArticlesApiProvider articlesApiProvider = Get.find();
  final RxnString rxnNewLiveUrl = RxnString();
  final RxList rxLiveCamList = RxList();

  @override
  void onInit() async {
    super.onInit();
    rxnNewLiveUrl.value = await articlesApiProvider.getNewsLiveUrl();
    rxLiveCamList.value = await articlesApiProvider.getLiveCamUrlList();

  }
}
