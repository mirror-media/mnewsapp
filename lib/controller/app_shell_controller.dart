import 'package:get/get.dart';
import 'package:tv/bindings/live_binding.dart';
import 'package:tv/controller/interstitial_ad_controller.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/pages/section/live/live_page_controller.dart';
import 'package:tv/pages/section/news/news_page_controller.dart';
import 'package:tv/pages/section/video/video_page_controller.dart';

class AppShellController extends GetxController {
  final InterstitialAdController interstitialAdController = Get.find();
  final Rx<MNewsSection> currentSection = MNewsSection.news.obs;

  @override
  void onInit() {
    super.onInit();
    activateSection(currentSection.value, showInterstitial: false);
  }

  void changeSection(MNewsSection section) {
    if (currentSection.value == section) {
      return;
    }

    currentSection.value = section;
    activateSection(section);
  }

  void activateSection(
    MNewsSection section, {
    bool showInterstitial = true,
  }) {
    if (showInterstitial && section != MNewsSection.ombuds) {
      interstitialAdController.ramdomShowInterstitialAd();
    }

    _cleanupSectionControllers();

    switch (section) {
      case MNewsSection.news:
        Get.put(NewsPageController());
        break;
      case MNewsSection.live:
        LiveBinding().dependencies();
        break;
      case MNewsSection.video:
        Get.put(VideoPageController());
        break;
      case MNewsSection.show:
      case MNewsSection.anchorperson:
      case MNewsSection.ombuds:
      case MNewsSection.programList:
      case MNewsSection.topicList:
        break;
    }
  }

  void _cleanupSectionControllers() {
    if (Get.isRegistered<NewsPageController>()) {
      Get.delete<NewsPageController>();
    }
    if (Get.isRegistered<LivePageController>()) {
      Get.delete<LivePageController>();
    }
    if (Get.isRegistered<VideoPageController>()) {
      Get.delete<VideoPageController>();
    }
  }
}
