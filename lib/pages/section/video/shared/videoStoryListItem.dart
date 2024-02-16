import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/data/value/string_default.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/pages/storyPage.dart';

class VideoStoryListItem extends StatelessWidget {
  final StoryListItem storyListItem;

  VideoStoryListItem({
    required this.storyListItem,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final TextScaleFactorController textScaleFactorController = Get.find();

    return InkWell(
        child: Column(
          children: [
            _displayStoryImage(
              storyListItem.photoUrl,
              width,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 0.0),
              child: Obx(
                () => ExtendedText(
                    storyListItem.name ?? StringDefault.nullString,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22.0,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textScaler: TextScaler.linear(
                        textScaleFactorController.textScaleFactor.value)),
              ),
            ),
          ],
        ),
        onTap: () {
          if (storyListItem.slug == null) return;
          Get.to(() => StoryPage(
                slug: storyListItem.slug!,
              ));
        });
  }

  Widget _displayStoryImage(String photoUrl, double width) {
    return SizedBox(
      height: width / 16 * 9,
      width: width,
      child: Stack(
        children: [
          CachedNetworkImage(
            height: width / 16 * 9,
            width: width,
            imageUrl: photoUrl,
            placeholder: (context, url) => Container(
              height: width / 16 * 9,
              width: width,
              color: Colors.grey,
            ),
            errorWidget: (context, url, error) => Container(
              height: width / 16 * 9,
              width: width,
              color: Colors.grey,
              child: Icon(Icons.error),
            ),
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 40.0 + 10.0,
                  color: Colors.black45,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_arrow,
                          size: 12,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '影音',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
