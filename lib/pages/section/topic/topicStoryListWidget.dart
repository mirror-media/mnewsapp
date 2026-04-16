import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/controller/interstitialAdController.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/controller/topic_story_controller.dart';
import 'package:tv/data/value/string_default.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/models/topicStoryList.dart';
import 'package:tv/pages/shared/editorChoice/carouselDisplayWidget.dart';
import 'package:tv/pages/shared/tabContentNoResultWidget.dart';
import 'package:tv/pages/storyPage.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';
import 'package:tv/widgets/story/mNewsVideoPlayer.dart';
import 'package:tv/widgets/youtube/youtubePlayer.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class TopicStoryListWidget extends StatefulWidget {
  const TopicStoryListWidget(this.slug, {super.key});

  final String slug;

  @override
  State<TopicStoryListWidget> createState() => _TopicStoryListWidgetState();
}

class _TopicStoryListWidgetState extends State<TopicStoryListWidget> {
  late final String _storySlug;
  late final TopicStoryController controller;
  late final carousel.CarouselSliderController carouselController;

  final interstitialAdController = Get.find<InterstitialAdController>();
  final TextScaleFactorController textScaleFactorController = Get.find();

  @override
  void initState() {
    super.initState();
    _storySlug = widget.slug;
    controller = Get.find<TopicStoryController>(tag: _storySlug);
    carouselController = carousel.CarouselSliderController();
    interstitialAdController.ramdomShowInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = controller.error.value;
      if (error != null) {
        if (error is NoInternetException) {
          return error.renderWidget(
            onPressed: controller.fetchTopicStoryList,
          );
        }
        return error.renderWidget();
      }

      final topicStoryList = controller.topicStoryList.value;
      final storyListItemList = controller.storyListItemList.toList();

      if (controller.isLoading.value && topicStoryList == null) {
        return const Center(child: CircularProgressIndicator.adaptive());
      }

      if (topicStoryList == null || storyListItemList.isEmpty) {
        return TabContentNoResultWidget();
      }

      return _buildBody(topicStoryList, storyListItemList);
    });
  }

  Widget _buildBody(
    TopicStoryList topicStoryList,
    List<StoryListItem> storyListItemList,
  ) {
    final width = MediaQuery.of(context).size.width;
    final height = width / 16 * 9;

    final firstFour = storyListItemList.take(4).toList();
    final fiveToEight = storyListItemList.skip(4).take(4).toList();
    final others = storyListItemList.skip(8).toList();

    return ListView(
      children: [
        InlineBannerAdWidget(
          adUnitId: AdUnitIdHelper.getBannerAdUnitId('TopicHD'),
          sizes: [AdSize.mediumRectangle, AdSize(width: 336, height: 280)],
          wantKeepAlive: true,
        ),
        _buildLeading(topicStoryList, width, height),
        const SizedBox(height: 16),
        _buildTopicStoryList(firstFour),
        InlineBannerAdWidget(
          adUnitId: AdUnitIdHelper.getBannerAdUnitId('TopicAT1'),
          sizes: [
            AdSize.mediumRectangle,
            AdSize(width: 336, height: 280),
            AdSize(width: 320, height: 480),
          ],
          wantKeepAlive: true,
        ),
        _buildTopicStoryList(fiveToEight),
        InlineBannerAdWidget(
          adUnitId: AdUnitIdHelper.getBannerAdUnitId('TopicAT2'),
          sizes: [AdSize.mediumRectangle, AdSize(width: 336, height: 280)],
          wantKeepAlive: true,
        ),
        _buildTopicStoryList(others),
        _loadMoreWidget(),
      ],
    );
  }

  Widget _buildLeading(
    TopicStoryList topicStoryList,
    double width,
    double height,
  ) {
    if (topicStoryList.leading == 'slideshow' &&
        topicStoryList.headerArticles != null &&
        topicStoryList.headerArticles!.isNotEmpty) {
      final items = topicStoryList.headerArticles!.map((item) {
        return CarouselDisplayWidget(
          storyListItem: item,
          width: width,
          isHomePage: false,
          showTag: false,
        );
      }).toList();

      double finalHeight = width / (16 / 9);
      if (finalHeight > 700) {
        finalHeight = 700;
      } else if (finalHeight > 500) {
        finalHeight = (finalHeight ~/ 100) * 100;
      }
      finalHeight += 120;

      return carousel.CarouselSlider(
        items: items,
        options: carousel.CarouselOptions(
          autoPlay: true,
          aspectRatio: 2.0,
          viewportFraction: 1.0,
          height: finalHeight,
        ),
      );
    }

    if (topicStoryList.leading == 'video' &&
        topicStoryList.headerVideo != null) {
      final videoUrl = topicStoryList.headerVideo!.url;
      if (videoUrl.contains('youtube')) {
        final videoId = VideoId.parseVideoId(videoUrl);
        return videoId == null
            ? const SizedBox()
            : YoutubePlayer(videoId, mute: true, autoPlay: true);
      }

      return MNewsVideoPlayer(
        videourl: videoUrl,
        aspectRatio: 16 / 9,
        autoPlay: true,
        muted: true,
      );
    }

    if (topicStoryList.leading == 'multivideo' &&
        topicStoryList.headerVideoList != null &&
        topicStoryList.headerVideoList!.isNotEmpty) {
      final items = topicStoryList.headerVideoList!.map((item) {
        final videoId = VideoId.parseVideoId(item.url);
        return videoId != null
            ? YoutubePlayer(videoId, autoPlay: true, mute: true)
            : const SizedBox.shrink();
      }).toList();

      return Column(
        children: [
          carousel.CarouselSlider(
            items: items,
            carouselController: carouselController,
            options: carousel.CarouselOptions(
              autoPlay: false,
              aspectRatio: 2.0,
              viewportFraction: 1.0,
              height: width / (16 / 9),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => carouselController.previousPage(),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_back_ios,
                        color: themeColor, size: 18),
                    const SizedBox(width: 13),
                    Obx(
                      () => Text(
                        '上一則影片',
                        style: const TextStyle(
                          color: themeColor,
                          fontSize: 14,
                        ),
                        textScaleFactor:
                            textScaleFactorController.textScaleFactor.value,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => carouselController.nextPage(),
                child: Row(
                  children: [
                    Obx(
                      () => Text(
                        '下一則影片',
                        style: const TextStyle(
                          color: themeColor,
                          fontSize: 14,
                        ),
                        textScaleFactor:
                            textScaleFactorController.textScaleFactor.value,
                      ),
                    ),
                    const SizedBox(width: 13),
                    const Icon(Icons.arrow_forward_ios,
                        color: themeColor, size: 18),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 29),
      child: CachedNetworkImage(
        width: width,
        imageUrl: topicStoryList.photoUrl,
        placeholder: (context, url) => Container(
          height: height,
          width: width,
          color: Colors.grey,
        ),
        errorWidget: (context, url, error) => Container(
          height: height,
          width: width,
          color: Colors.grey,
          child: const Icon(Icons.error),
        ),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTopicStoryList(List<StoryListItem> list) {
    return ListView.separated(
      itemCount: list.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const Divider(
        height: 16,
        thickness: 1,
        color: Color.fromRGBO(244, 245, 246, 1),
        indent: 24,
        endIndent: 27,
      ),
      itemBuilder: (context, index) => InkWell(
        onTap: () {
          final slug = list[index].slug;
          if (slug == null) return;
          Get.to(() => StoryPage(slug: slug));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildTopicStoryListItem(list[index]),
        ),
      ),
    );
  }

  Widget _buildTopicStoryListItem(StoryListItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2.0),
          child: SizedBox(
            width: 90,
            height: 90,
            child: CachedNetworkImage(
              imageUrl: item.photoUrl,
              placeholder: (context, url) => Container(
                height: 90,
                width: 90,
                color: Colors.grey,
              ),
              errorWidget: (context, url, error) => Container(
                height: 90,
                width: 90,
                color: Colors.grey,
                child: const Icon(Icons.error),
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 90,
          width: MediaQuery.of(context).size.width - 90 - 12 - 48,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  item.name ?? StringDefault.nullString,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textScaleFactor:
                      textScaleFactorController.textScaleFactor.value,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                  ),
                ),
              ),
              if (item.categoryList != null && item.categoryList!.isNotEmpty)
                Container(
                  color: const Color.fromRGBO(151, 151, 151, 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  width: 50,
                  alignment: Alignment.center,
                  child: Obx(
                    () => Text(
                      item.categoryList![0].name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor:
                          textScaleFactorController.textScaleFactor.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _loadMoreWidget() {
    if (controller.isAllLoaded.value) {
      return const SizedBox(height: 28);
    }

    return VisibilityDetector(
      key: const Key('TopicStoryListLoadingMore'),
      onVisibilityChanged: (info) {
        final percent = info.visibleFraction * 100;
        if (percent > 30 && !controller.isLoadingMore.value) {
          controller.fetchTopicStoryListMore();
        }
      },
      child: Obx(
        () => controller.isLoadingMore.value
            ? const Center(child: CircularProgressIndicator.adaptive())
            : const SizedBox(height: 28),
      ),
    );
  }
}
