import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/story.dart';
import 'package:tv/models/video.dart' as my_video;
import 'package:tv/services/storyService.dart';
import 'package:tv/services/videoService.dart';

class OmbudsController extends GetxController {
  OmbudsController({
    required this.storyService,
    required this.videoService,
  });

  final StoryServices storyService;
  final VideoServices videoService;

  final Rxn<Story> story = Rxn<Story>();
  final Rxn<my_video.Video> video = Rxn<my_video.Video>();
  final RxBool isLoading = false.obs;
  final Rxn<MNewException> error = Rxn<MNewException>();

  @override
  void onInit() {
    super.onInit();
    loadOmbuds();
  }

  Future<void> loadOmbuds() async {
    isLoading.value = true;
    error.value = null;

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
}
