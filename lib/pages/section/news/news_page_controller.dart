import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';
import 'package:tv/provider/articles_api_provider.dart';

class NewsPageController extends GetxController {
  ArticlesApiProvider articlesApiProvider = Get.find();
  FirebaseRemoteConfig firebaseRemoteConfig = FirebaseRemoteConfig.instance;
  final RxnString rxnNewLiveUrl = RxnString();
  final RxList rxLiveCamList = RxList();
  final RxBool rxIsElectionShow = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await firebaseRemoteConfig.fetchAndActivate();
    rxIsElectionShow.value = firebaseRemoteConfig.getBool('isElectionShow');
    rxnNewLiveUrl.value = await articlesApiProvider.getNewsLiveUrl();
    rxLiveCamList.value = await articlesApiProvider.getLiveCamUrlList();
  }
}
