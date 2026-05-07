import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/controller/news_story_list_controller.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/pages/section/news/shared/news_story_first_item.dart';
import 'package:tv/pages/section/news/shared/news_story_list_item.dart';
import 'package:tv/widgets/tab_content_no_result_widget.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';

class NewsPopularTabStoryList extends StatefulWidget {
  const NewsPopularTabStoryList({
    super.key,
    required this.controllerTag,
  });

  final String controllerTag;

  @override
  State<NewsPopularTabStoryList> createState() =>
      _NewsPopularTabStoryListState();
}

class _NewsPopularTabStoryListState extends State<NewsPopularTabStoryList> {
  late final NewsStoryListController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<NewsStoryListController>(tag: widget.controllerTag);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = controller.error.value;
      if (error != null) {
        if (error is NoInternetException) {
          return error.renderWidget(
            onPressed: controller.fetchInitial,
            isColumn: true,
          );
        }

        return TabContentNoResultWidget();
      }

      final storyListItemList = controller.storyList.toList();
      if (storyListItemList.isNotEmpty) {
        return tabStoryList(storyListItemList: storyListItemList);
      }

      if (!controller.isLoading.value) {
        return TabContentNoResultWidget();
      }

      return const Center(child: CircularProgressIndicator.adaptive());
    });
  }

  Widget tabStoryList({
    required List<StoryListItem> storyListItemList,
  }) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == 0) {
          return NewsStoryFirstItem(
            storyListItem: storyListItemList[0],
          );
        } else if (index == 1) {
          return InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('NewsAT1'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
            ],
          );
        }

        return NewsStoryListItem(
          storyListItem: storyListItemList[index - 1],
        );
      },
      separatorBuilder: (context, index) {
        if (index == 6) {
          return InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('NewsAT2'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
            ],
          );
        } else if (index == 11) {
          return InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('NewsAT3'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
            ],
          );
        }
        return const SizedBox(height: 16);
      },
      itemCount: storyListItemList.length + 1,
    );
  }
}
