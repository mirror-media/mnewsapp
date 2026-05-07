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
import 'package:visibility_detector/visibility_detector.dart';

class NewsTabStoryList extends StatefulWidget {
  const NewsTabStoryList({
    super.key,
    required this.controllerTag,
    required this.categorySlug,
    this.needCarousel = false,
  });

  final String controllerTag;
  final String categorySlug;
  final bool needCarousel;

  @override
  State<NewsTabStoryList> createState() => _NewsTabStoryListState();
}

class _NewsTabStoryListState extends State<NewsTabStoryList> {
  late final NewsStoryListController controller;
  late final Worker loadMoreErrorWorker;

  @override
  void initState() {
    super.initState();
    controller = Get.find<NewsStoryListController>(tag: widget.controllerTag);
    loadMoreErrorWorker = ever<String?>(
      controller.loadMoreErrorMessage,
      (message) {
        if (message == null || !mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
        controller.clearLoadMoreErrorMessage();
      },
    );
  }

  @override
  void dispose() {
    loadMoreErrorWorker.dispose();
    super.dispose();
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

        return error.renderWidget(isNoButton: true, isColumn: true);
      }

      final storyListItemList = controller.storyList.toList();
      if (storyListItemList.isEmpty && !controller.isLoading.value) {
        return TabContentNoResultWidget();
      }

      if (storyListItemList.isNotEmpty) {
        return tabStoryList(
          storyListItemList: storyListItemList,
          needCarousel: widget.needCarousel,
        );
      }

      return const Center(child: CircularProgressIndicator.adaptive());
    });
  }

  Widget tabStoryList({
    required List<StoryListItem> storyListItemList,
    bool needCarousel = false,
  }) {
    final itemCount = storyListItemList.length + 2;

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == itemCount - 1) {
          if (controller.isAllLoaded.value) {
            return Container();
          }

          return VisibilityDetector(
            key: Key('TabStoryListLoadingMore_${widget.controllerTag}'),
            onVisibilityChanged: (visibilityInfo) {
              final visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage > 30 && !controller.isLoadingMore.value) {
                controller.fetchNextPage();
              }
            },
            child: loadMoreWidget(),
          );
        }

        if (!needCarousel) {
          if (index == 0) {
            return NewsStoryFirstItem(
              storyListItem: storyListItemList[0],
              categorySlug: widget.categorySlug,
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
        }

        if (index == 0) {
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
          categorySlug: widget.categorySlug,
        );
      },
      separatorBuilder: (context, index) {
        if ((!needCarousel && index == 6) || (needCarousel && index == 5)) {
          return InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('NewsAT2'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
              AdSize(width: 320, height: 480),
            ],
          );
        } else if ((!needCarousel && index == 11) ||
            (needCarousel && index == 10)) {
          return InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('NewsAT3'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
            ],
          );
        } else if (needCarousel && index == 0) {
          return Container();
        }
        return const SizedBox(height: 16);
      },
      itemCount: itemCount,
    );
  }

  Widget loadMoreWidget() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
