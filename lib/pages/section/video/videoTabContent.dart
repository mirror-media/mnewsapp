import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/core/enum/page_status.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/pages/section/video/shared/videoStoryListItem.dart';
import 'package:tv/pages/section/video/video_tab_controller.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';

class VideoTabContent extends StatelessWidget {
  final String categorySlug;
  final bool isFeaturedSlug;

  VideoTabContent({
    required this.categorySlug,
    this.isFeaturedSlug = false,
  });

  @override
  Widget build(BuildContext context) {
    VideoTabController controller = Get.find(tag: categorySlug);
    if (isFeaturedSlug) {
      AnalyticsHelper.sendScreenView(
          screenName: 'VideoPage categorySlug=featured');
    } else {
      AnalyticsHelper.sendScreenView(
          screenName: 'VideoPage categorySlug=$categorySlug');
    }
    return Column(
      children: [
        Obx(() {
          final storyList = controller.rxStoryList;
          return Expanded(
            child: ListView.separated(
                controller: controller.scrollController,
                itemBuilder: (context, index) {
                  return VideoStoryListItem(storyListItem: storyList[index]);
                },
                separatorBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return InlineBannerAdWidget(
                        adUnitId: AdUnitIdHelper.getBannerAdUnitId('VideoAT1'),
                        sizes: [
                          AdSize.mediumRectangle,
                          AdSize(width: 336, height: 280),
                        ],
                      );
                    case 3:
                      return InlineBannerAdWidget(
                        adUnitId: AdUnitIdHelper.getBannerAdUnitId('VideoAT2'),
                        sizes: [
                          AdSize.mediumRectangle,
                          AdSize(width: 336, height: 280),
                          AdSize(width: 320, height: 480),
                        ],
                      );
                    case 6:
                      return InlineBannerAdWidget(
                        adUnitId: AdUnitIdHelper.getBannerAdUnitId('VideoAT3'),
                        sizes: [
                          AdSize.mediumRectangle,
                          AdSize(width: 336, height: 280),
                        ],
                      );
                    default:
                      return const SizedBox(height: 24);
                  }
                },
                itemCount: storyList.length),
          );
        }),
        Obx(() {
          final pageStatus = controller.rxPageStatus.value;
          return pageStatus == PageStatus.loading
              ? Center(child: CircularProgressIndicator())
              : const SizedBox.shrink();
        }),
      ],
    );
  }
}
