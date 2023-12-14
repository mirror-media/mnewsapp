import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/core/extensions/string_extension.dart';
import 'package:tv/data/value/string_default.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:tv/pages/section/show/election_show_story_page/election_show_story_binding.dart';
import 'package:tv/pages/section/show/election_show_story_page/election_show_story_page.dart';

class PlaylistItem extends StatelessWidget {
  const PlaylistItem({required this.playlistItem, required this.tag});

  final YoutubePlaylistItem playlistItem;
  final String tag;

  @override
  Widget build(BuildContext context) {
    double imageWidth = 33.3 * (Get.width - 48) / 100;
    double imageHeight = imageWidth / 16 * 9;
    final TextScaleFactorController textScaleFactorController = Get.find();

    return InkWell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedNetworkImage(
            height: imageHeight,
            width: imageWidth,
            imageUrl: playlistItem.photoUrl,
            placeholder: (context, url) => Container(
              height: imageHeight,
              width: imageWidth,
              color: Colors.grey,
            ),
            errorWidget: (context, url, error) => Container(
              height: imageHeight,
              width: imageWidth,
              color: Colors.grey,
              child: Icon(Icons.error),
            ),
            fit: BoxFit.cover,
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => ExtendedText(
                    playlistItem.name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textScaleFactor:
                        textScaleFactorController.textScaleFactor.value,
                  ),
                ),
                if (playlistItem.publishedAt != null) ...[
                  SizedBox(height: 12),
                  Text(
                    playlistItem.publishedAt?.convertToDisplayText() ??
                        StringDefault.nullString,
                    style: TextStyle(
                      color: Color(0xff757575),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      onTap: () {
        Get.off(
            () => ElectionShowStoryPage(
                  tag: tag,
                  youtubePlaylistItem: playlistItem,
                ),
            binding: ElectionShowStoryBinding(tag),
            preventDuplicates: false);
      },
    );
  }
}
