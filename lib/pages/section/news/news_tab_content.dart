import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/bindings/news_story_list_binding.dart';
import 'package:tv/controller/news_story_list_controller.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/pages/section/news/election/election_widget.dart';
import 'package:tv/pages/section/news/news_page_controller.dart';
import 'package:tv/pages/section/news/news_popular_tab_story_list.dart';
import 'package:tv/pages/section/news/news_tab_story_list.dart';
import 'package:tv/widgets/editor_choice/editor_choice_carousel.dart' as cs;
import 'package:tv/widgets/liveWidget.dart';
import 'package:tv/widgets/real_time_invoice/real_time_invoice/real_time_invoice_widget.dart';
import 'package:tv/widgets/youtube_stream_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsTabContent extends StatefulWidget {
  const NewsTabContent({
    super.key,
    required this.categorySlug,
    this.needCarousel = false,
    this.showElectionBlock = false,
  });

  final String categorySlug;
  final bool needCarousel;
  final bool showElectionBlock;

  @override
  State<NewsTabContent> createState() => _NewsTabContentState();
}

class _NewsTabContentState extends State<NewsTabContent> {
  late final String controllerTag;

  @override
  void initState() {
    super.initState();
    controllerTag = 'news_${widget.categorySlug}';
    NewsStoryListBinding(
      controllerTag: controllerTag,
      categorySlug: widget.categorySlug,
      needCarousel: widget.needCarousel,
      isPopular: widget.categorySlug == 'popular',
    ).dependencies();
  }

  @override
  void dispose() {
    if (Get.isRegistered<NewsStoryListController>(tag: controllerTag)) {
      Get.delete<NewsStoryListController>(tag: controllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categorySlug == 'latest') {
      AnalyticsHelper.sendScreenView(screenName: 'HomePage');
    } else {
      AnalyticsHelper.sendScreenView(
        screenName: 'NewsPage categorySlug=${widget.categorySlug}',
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          if (widget.showElectionBlock) ElectionWidget(),
          if (widget.needCarousel) NewsTopFeature(controllerTag: controllerTag),
          widget.categorySlug == 'popular'
              ? NewsPopularTabStoryList(controllerTag: controllerTag)
              : NewsTabStoryList(
                  controllerTag: controllerTag,
                  categorySlug: widget.categorySlug,
                  needCarousel: widget.needCarousel,
                ),
        ],
      ),
    );
  }
}

class NewsTopFeature extends StatelessWidget {
  NewsTopFeature({
    super.key,
    required this.controllerTag,
  });

  final String controllerTag;
  final NewsPageController pageController = Get.find();

  @override
  Widget build(BuildContext context) {
    final listController = Get.find<NewsStoryListController>(tag: controllerTag);
    return Obx(() {
      final editorChoiceList = listController.editorChoiceList;
      final storyList = listController.storyList;
      final isLoading = listController.isLoading.value;

      if (isLoading && storyList.isEmpty) {
        return const SizedBox();
      }

      if (editorChoiceList.isEmpty) {
        if (storyList.isNotEmpty) {
          return Column(
            children: [
              LiveWidget(
                needBuildLiveTitle: false,
                livePostId: Environment().config.mNewsLivePostId,
              ),
              const SizedBox(height: 12),
            ],
          );
        }
        return const SizedBox();
      }

      return Column(
        children: [
          Obx(() {
            final isElectionShow = pageController.rxIsElectionShow.value;
            return isElectionShow
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 27),
                        child: RealTimeInvoiceWidget(
                          getMoreButtonClick: () async {
                            if (!await launchUrl(Uri.parse(
                                Environment().config.electionGetMoreWebpage))) {
                              throw Exception('Could not launch');
                            }
                          },
                          width: Get.width - 54,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  )
                : const SizedBox.shrink();
          }),
          Obx(() {
            final mnewLiveUrl = pageController.rxnNewLiveUrl.value;
            return mnewLiveUrl != null
                ? Column(
                    children: [
                      YoutubeStreamWidget(youtubeUrl: mnewLiveUrl),
                      const SizedBox(height: 12),
                    ],
                  )
                : const SizedBox.shrink();
          }),
          Obx(() {
            final liveCameList = pageController.rxLiveCamList;
            return liveCameList.isNotEmpty
                ? Column(
                    children: [
                      YoutubeStreamWidget(youtubeUrl: liveCameList[0]),
                      const SizedBox(height: 12),
                    ],
                  )
                : const SizedBox.shrink();
          }),
          const SizedBox(height: 12),
          cs.EditorChoiceCarousel(
            editorChoiceList: editorChoiceList,
            aspectRatio: 4 / 3.2,
          ),
        ],
      );
    });
  }
}
