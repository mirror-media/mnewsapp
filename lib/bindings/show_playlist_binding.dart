import 'package:get/get.dart';
import 'package:tv/controller/show_playlist_controller.dart';
import 'package:tv/services/youtubePlaylistService.dart';

class ShowPlaylistBinding extends Bindings {
  ShowPlaylistBinding({
    required this.controllerTag,
    required this.playlistId,
    required this.maxResults,
  });

  final String controllerTag;
  final String playlistId;
  final int maxResults;

  @override
  void dependencies() {
    if (!Get.isRegistered<YoutubePlaylistServices>(tag: controllerTag)) {
      Get.lazyPut(
        () => YoutubePlaylistServices(),
        tag: controllerTag,
      );
    }

    if (!Get.isRegistered<ShowPlaylistController>(tag: controllerTag)) {
      Get.lazyPut(
        () => ShowPlaylistController(
          playlistId: playlistId,
          maxResults: maxResults,
          youtubePlaylistService:
              Get.find<YoutubePlaylistServices>(tag: controllerTag),
        ),
        tag: controllerTag,
      );
    }
  }
}
