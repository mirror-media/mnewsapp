import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/data/value/string_default.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/pages/storyPage.dart';

class CarouselDisplayWidget extends StatelessWidget {
  final StoryListItem storyListItem;
  final double width;
  final bool isHomePage;
  final bool showTag;

  CarouselDisplayWidget({
    required this.storyListItem,
    required this.width,
    this.isHomePage = true,
    this.showTag = true,
  });

  final double aspectRatio = 16 / 9;
  final TextScaleFactorController textScaleFactorController = Get.find();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(
        children: [
          Stack(
            children: [
              _displayImage(width, storyListItem),
              if (showTag)
                Align(
                  alignment: Alignment.topLeft,
                  child: _displayTag(),
                ),
            ],
          ),
          Expanded(child: _displayTitle(storyListItem)),
        ],
      ),
      onTap: () {
        if (isHomePage) {
          AnalyticsHelper.logClick(
              slug: storyListItem.slug ?? StringDefault.nullString,
              title: storyListItem.name ?? StringDefault.nullString,
              location: 'HomePage_編輯精選');
        }
        if (storyListItem.slug == null) return;
        Get.to(() => StoryPage(
              slug: storyListItem.slug!,
            ));
      },
    );
  }

  Widget _displayImage(double width, StoryListItem storyListItem) {
    return CachedNetworkImage(
      height: width / aspectRatio,
      width: width,
      imageUrl: storyListItem.photoUrl,
      placeholder: (context, url) => Container(
        height: width / aspectRatio,
        width: width,
        color: Colors.grey,
      ),
      errorWidget: (context, url, error) => Container(
        height: width / aspectRatio,
        width: width,
        color: Colors.grey,
        child: Icon(Icons.error),
      ),
      fit: BoxFit.cover,
    );
  }

  Widget _displayTag() {
    return Container(
      decoration: BoxDecoration(
        color: editorChoiceTagColor,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: Text(
          '編輯精選',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _displayTitle(StoryListItem storyListItem) {
    return Container(
      color: editorChoiceTitleBackgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
          child: Obx(
            () => ExtendedText(
              storyListItem.name ?? StringDefault.nullString,
              joinZeroWidthSpace: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.0,
              ),
              textScaleFactor: textScaleFactorController.textScaleFactor.value,
            ),
          ),
        ),
      ),
    );
  }
}
