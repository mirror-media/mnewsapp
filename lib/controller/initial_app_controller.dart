import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:real_time_invoice_widget/data/provider/election_data_provider.dart';
import 'package:tv/configs/prodConfig.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/provider/articles_api_provider.dart';
import 'package:tv/services/configService.dart';

class InitialAppController extends GetxController {
  InitialAppController({
    required this.configRepos,
  });

  final ConfigRepos configRepos;

  final RxBool isLoading = false.obs;
  final Rxn<MNewException> error = Rxn<MNewException>();
  final RxBool isConfigReady = false.obs;
  final RxString minAppVersion = ''.obs;
  final RxString appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadConfig();
  }

  Future<void> loadConfig() async {
    isLoading.value = true;
    error.value = null;
    isConfigReady.value = false;

    try {
      final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(minutes: 10),
        ),
      );

      await remoteConfig.setDefaults({
        'min_version_number': '',
        'use_temporary_k6_routes': false,
      });

      await remoteConfig.fetchAndActivate();

      minAppVersion.value = remoteConfig.getString('min_version_number');
      final bool useTemporaryK6Routes =
          remoteConfig.getBool('use_temporary_k6_routes');

      Environment().initConfig(
        BuildFlavor.production,
        routeMode: useTemporaryK6Routes
            ? ProdRouteMode.temporaryK6
            : ProdRouteMode.normal,
      );

      ArticlesApiProvider.instance.initGraphQLLink();
      _refreshElectionDataProvider();
      await configRepos.loadTheConfig();
      await MobileAds.instance.initialize();

      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion.value =
          'v${packageInfo.version}(${packageInfo.buildNumber})';
      isConfigReady.value = true;
    } catch (e) {
      error.value = UnknownException(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _refreshElectionDataProvider() {
    if (Get.isRegistered<ElectionDataProvider>()) {
      Get.delete<ElectionDataProvider>();
    }

    Get.put(
      ElectionDataProvider.create(Environment().config.electionPath),
      permanent: true,
    );
  }
}
