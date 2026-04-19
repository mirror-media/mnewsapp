import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/pages/section/video/video_page_controller.dart';
import 'package:tv/pages/shared/newsMarquee/newsMarqueeWidget.dart';

class VideoPage extends GetView<VideoPageController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: tabBarColor,
          width: double.infinity,
          alignment: Alignment.topCenter,
          child: Obx(() {
            final tabList = controller.rxCategoryList
                .map((category) => Tab(
                        child: Text(
                      category.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textScaleFactor: controller
                          .textScaleFactorController.textScaleFactor.value,
                    )))
                .toList();
            final isLoadingFinish = controller.rxIsLoadingFinish.value;
            return isLoadingFinish
                ? Center(
                    child: TabBar(
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      indicatorColor: tabBarSelectedColor,
                      unselectedLabelColor: tabBarUnselectedColor,
                      labelColor: tabBarSelectedColor,
                      tabs: tabList,
                      controller: controller.tabController,
                    ),
                  )
                : SizedBox.shrink();
          }),
        ),

        const Padding(
          padding: EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 12.0),
          child: BuildNewsMarquee(tag: 'video_marquee'),
        ),
        Obx(() {
          final isLoadingFinish = controller.rxIsLoadingFinish.value;
          final tabContentList = controller.rxVideoTabContent;
          return isLoadingFinish
              ? Expanded(
                  child: TabBarView(
                    controller: controller.tabController,
                    children: tabContentList,
                  ),
                )
              : Center(child: CircularProgressIndicator());
        }),
      ],
    );
  }
}
