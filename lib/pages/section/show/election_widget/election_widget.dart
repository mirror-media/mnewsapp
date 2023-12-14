import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/data/value/string_default.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/pages/section/show/election_show_story_page/election_show_story_binding.dart';
import 'package:tv/pages/section/show/election_show_story_page/election_show_story_page.dart';
import 'package:tv/pages/section/show/election_widget/election_controller.dart';
import 'package:tv/pages/section/show/election_widget/widget/podcast_list_widget.dart';
import 'package:tv/pages/section/show/election_widget/widget/youtube_list_item.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';
import 'package:tv/widgets/podcast_sticky_panel/podcast_sticky_panel.dart';

class ElectionWidget extends StatefulWidget {
  const ElectionWidget({required this.tag});

  final String tag;

  @override
  State<ElectionWidget> createState() => _ElectionWidgetState();
}

class _ElectionWidgetState extends State<ElectionWidget> {
  late ElectionController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ElectionController>(tag: widget.tag)) {
      Get.put(ElectionController(widget.tag), tag: widget.tag);
    }
    controller = Get.find<ElectionController>(tag: widget.tag);
  }

  @override
  Widget build(BuildContext context) {
    double width = Get.width;
    double height = width / 375 * 140;
    return Obx(() {
      final showIntro = controller.rxnShowIntro.value;
      return showIntro == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        width: width,
                        height: 160,
                        imageUrl:
                            controller.rxnShowIntro.value?.pictureUrl ?? '',
                        placeholder: (context, url) => Container(
                          height: height,
                          width: width,
                          color: Colors.grey,
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: height,
                          width: width,
                          color: Colors.grey,
                          child: Icon(Icons.error),
                        ),
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 24),
                        child: Obx(
                          () => Text(
                            controller.rxnShowIntro.value?.name ??
                                StringDefault.nullString,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                            textScaleFactor: controller
                                .textScaleFactorController
                                .textScaleFactor
                                .value,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 24),
                        child: Obx(
                          () => Text(
                            controller.rxnShowIntro.value?.introduction ??
                                StringDefault.nullString,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                            ),
                            textScaleFactor: controller
                                .textScaleFactorController
                                .textScaleFactor
                                .value,
                          ),
                        ),
                      ),
                      InlineBannerAdWidget(
                        adUnitId: AdUnitIdHelper.getBannerAdUnitId('ShowAT1'),
                        sizes: [
                          AdSize.mediumRectangle,
                          AdSize(width: 336, height: 280),
                        ],
                      ),
                      SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            SizedBox(
                              width: width,
                              child: Obx(() {
                                final showIntro = controller.rxnShowIntro.value;
                                return CupertinoSegmentedControl<int>(
                                    padding: const EdgeInsets.all(0),
                                    borderColor: Color(0xff004DBC),
                                    selectedColor: Color(0xff004DBC),
                                    groupValue: controller
                                        .rxSegmentedControlValue.value,
                                    children: {
                                      0: Text(
                                        showIntro?.playList01?.name ??
                                            StringDefault.nullString,
                                        textScaleFactor: controller
                                            .textScaleFactorController
                                            .textScaleFactor
                                            .value,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      1: Text(
                                        showIntro?.playList02?.name ??
                                            StringDefault.nullString,
                                        textScaleFactor: controller
                                            .textScaleFactorController
                                            .textScaleFactor
                                            .value,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    },
                                    onValueChanged:
                                        controller.segmentedControlValueChange);
                              }),
                            ),
                            SizedBox(height: 24),
                            // _tabWidgets[_segmentedControlGroupValue],
                          ],
                        ),
                      ),
                      Obx(() {
                        final renderList =
                            controller.rxSegmentedControlValue.value == 0
                                ? controller.rxYoutubePlayRenderList
                                : controller.rxYoutubeShortRenderList;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                          child: ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return YoutubeListItem(
                                  item: renderList[index],
                                  itemClickEvent: () {
                                    controller.podcastStickyPanelController
                                        .audioPlayer
                                        ?.pause();
                                    Get.to(
                                        () => ElectionShowStoryPage(
                                              tag: controller.tag ?? '',
                                              youtubePlaylistItem:
                                                  renderList[index],
                                            ),
                                        binding: ElectionShowStoryBinding(
                                            controller.tag ?? ''),
                                        preventDuplicates: false);
                                  },
                                );
                              },
                              separatorBuilder: (context, index) {
                                if (index == 5) {
                                  return Align(
                                    alignment: Alignment.center,
                                    child: InlineBannerAdWidget(
                                      adUnitId:
                                          AdUnitIdHelper.getBannerAdUnitId(
                                              'ShowAT2'),
                                      sizes: [
                                        AdSize.mediumRectangle,
                                        AdSize(width: 336, height: 280),
                                        AdSize(width: 320, height: 480),
                                      ],
                                      addHorizontalMargin: false,
                                    ),
                                  );
                                } else if (index == 10) {
                                  return Align(
                                    alignment: Alignment.center,
                                    child: InlineBannerAdWidget(
                                      adUnitId:
                                          AdUnitIdHelper.getBannerAdUnitId(
                                              'ShowAT3'),
                                      sizes: [
                                        AdSize.mediumRectangle,
                                        AdSize(width: 336, height: 280),
                                      ],
                                      addHorizontalMargin: false,
                                    ),
                                  );
                                }

                                return const SizedBox(height: 16.0);
                              },
                              itemCount: renderList.length),
                        );
                      }),
                      Obx(() {
                        final invisible =
                            controller.rxSegmentedControlValue.value == 0
                                ? controller
                                        .rxPlayListInfo.value?.nextPageToken ==
                                    null
                                : controller.rxShortPlayListInfo.value
                                        ?.nextPageToken ==
                                    null;
                        return Visibility(
                          visible: !invisible,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 44),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xFF014DB8))),
                              child: TextButton(
                                onPressed: () {
                                  controller.getMorePlayList();
                                },
                                child: Text(
                                  '看更多',
                                  style: TextStyle(
                                      fontSize: 20, color: Color(0xFF014DB8)),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                      Obx(() {
                        final podcastList = controller.rxPodcastInfoList;
                        final selectPodcastInfo =
                            controller.rxnSelectPodcastInfo.value;
                        final displayCount =
                            controller.rxPodcastDisplayCount.value;
                        return podcastList.isNotEmpty
                            ? PodcastListWidget(
                                podcastInfoList: podcastList,
                                displayCount: displayCount,
                                selectedPodcastInfo: selectPodcastInfo,
                                itemClickEvent: (podcastInfo) => controller
                                    .podcastItemClickEvent(podcastInfo),
                              )
                            : SizedBox.shrink();
                      }),
                      Obx(() {
                        final invisible =
                            controller.rxPodcastDisplayCount.value ==
                                controller.rxPodcastInfoList.length;
                        return Visibility(
                          visible: !invisible,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 44),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xFF014DB8))),
                              child: TextButton(
                                onPressed: () {
                                  controller.getMorePodcast();
                                },
                                child: Text(
                                  '看更多',
                                  style: TextStyle(
                                      fontSize: 20, color: Color(0xFF014DB8)),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 150),
                    ],
                  ),
                ),
                AnimatedBuilder(
                    animation: controller.animation,
                    builder: (BuildContext context, Widget? child) {
                      return Positioned(
                        bottom: controller.animation.value,
                        child: Obx(() {
                          final podcastInfo =
                              controller.rxnSelectPodcastInfo.value;
                          return PodcastStickyPanel(
                            height: 130,
                            tag: controller.tag,
                            width: Get.width,
                            podcastInfo: podcastInfo,
                          );
                        }),
                      );
                    }),
              ],
            );
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}
