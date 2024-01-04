import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/data/value/string_default.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/pages/storyPage.dart';

class NewsStoryFirstItem extends StatelessWidget {
  final StoryListItem storyListItem;
  final String categorySlug;

  NewsStoryFirstItem({
    required this.storyListItem,
    this.categorySlug = 'latest',
  });

  @override
  Widget build(BuildContext context) {
    final TextScaleFactorController textScaleFactorController = Get.find();
    double width = MediaQuery.of(context).size.width;
    return InkWell(
        child: Column(
          children: [
            CachedNetworkImage(
              height: width / 16 * 9,
              width: width,
              imageUrl: storyListItem.photoUrl,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: Obx(
                () => ExtendedText(
                  storyListItem.name ?? StringDefault.nullString,
                  joinZeroWidthSpace: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    height: 1.5,
                  ),
                  textScaleFactor:
                      textScaleFactorController.textScaleFactor.value,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          AnalyticsHelper.logClick(
            slug: storyListItem.slug ?? StringDefault.nullString,
            title: storyListItem.name ?? StringDefault.nullString,
            location:
                categorySlug == 'latest' ? 'HomePage_最新列表' : 'CategoryPage_列表',
          );
          Get.to(() => StoryPage(
                slug: storyListItem.slug ?? StringDefault.nullString,
              ));
        });
  }
}
