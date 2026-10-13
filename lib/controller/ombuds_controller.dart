import 'dart:async';

import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/story.dart';
import 'package:tv/models/video.dart' as my_video;
import 'package:tv/services/ombuds_title_service.dart';
import 'package:tv/services/storyService.dart';
import 'package:tv/services/videoService.dart';

class OmbudsController extends GetxController {
  OmbudsController({
    required this.storyService,
    required this.videoService,
    required this.titleService,
  });

  static const fallbackTitle = '外部公評人莊豐嘉';

  final StoryServices storyService;
  final VideoServices videoService;
  final OmbudsTitleService titleService;

  final RxString title = fallbackTitle.obs;
  final Rxn<Story> story = Rxn<Story>();
  final Rxn<my_video.Video> video = Rxn<my_video.Video>();
  final RxBool isLoading = false.obs;
  final Rxn<MNewException> error = Rxn<MNewException>();
  int _titleRequestId = 0;

  @override
  void onInit() {
    super.onInit();
    loadOmbuds();
  }

  Future<void> loadOmbuds() async {
    isLoading.value = true;
    error.value = null;
    unawaited(_loadTitle());

    try {
      story.value = await storyService.fetchPublishedStoryBySlug('biography');
    } catch (e) {
      error.value = determineException(e);
      isLoading.value = false;
      return;
    }

    try {
      video.value = await videoService.fetchVideoByName(
        'ombuds_office_main_video',
      );
    } catch (_) {
      video.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadTitle() async {
    final requestId = ++_titleRequestId;
    try {
      final fetchedTitle = await titleService.fetchTitle();
      if (!isClosed &&
          requestId == _titleRequestId &&
          fetchedTitle != null &&
          fetchedTitle.isNotEmpty) {
        title.value = fetchedTitle;
      }
    } catch (_) {
      // Keep the last title (or the fallback) without blocking the introduction.
    }
  }
}
