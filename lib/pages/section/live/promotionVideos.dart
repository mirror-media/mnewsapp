import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/pages/section/live/live_page_controller.dart';
import 'package:tv/widgets/youtube/youtubePlayer.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PromotionVideos extends GetView<LivePageController> {
  const PromotionVideos({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final youtubePlaylistItemList = controller.rxPromotionVideoList;
      final error = controller.promotionVideosError.value;

      if (error != null) {
        debugPrint('PromotionVideosError: ${error.message}');
        return Container();
      }

      if (youtubePlaylistItemList.isEmpty) {
        return Container();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: _buildTitle('發燒單元'),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 16.0),
            itemCount: youtubePlaylistItemList.length,
            itemBuilder: (context, index) {
              return ytPlayer(
                context,
                youtubePlaylistItemList[index].youtubeVideoId,
                index,
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildTitle(String title) {
    final TextScaleFactorController textScaleFactorController = Get.find();
    return Obx(
      () => Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
        textScaleFactor: textScaleFactorController.textScaleFactor.value,
      ),
    );
  }

  Widget ytPlayer(BuildContext context, String videoID, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          controller.selectPromotionVideo(index);
        },
        child: Obx(() {
          final isSelected =
              controller.selectedPromotionVideoIndex.value == index;
          return !isSelected
              ? Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (kIsWeb && constraints.maxWidth > 800) {
                              return Container(
                                color: Colors.transparent,
                                padding: const EdgeInsets.all(5),
                                width: MediaQuery.of(context).size.width / 2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(
                                    ThumbnailSet(videoID).maxResUrl,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                color: Colors.transparent,
                                width: MediaQuery.of(context).size.width * 2,
                                child: Image.network(
                                  ThumbnailSet(videoID).maxResUrl,
                                  fit: BoxFit.fill,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.play_circle_filled,
                      color: Colors.white,
                      size: 55.0,
                    ),
                  ],
                )
              : YoutubePlayer(
                  videoID,
                  autoPlay: true,
                );
        }),
      ),
    );
  }
}
