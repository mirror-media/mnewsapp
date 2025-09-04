import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/blocs/topicStoryList/bloc.dart';
import 'package:tv/controller/interstitialAdController.dart';
import 'package:tv/controller/textScaleFactorController.dart';
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
  final String slug;

  const TopicStoryListWidget(this.slug, {super.key});

  @override
  State<TopicStoryListWidget> createState() => _TopicStoryListWidgetState();
}

class _TopicStoryListWidgetState extends State<TopicStoryListWidget> {
  late TopicStoryList _topicStoryList;
  late final String _storySlug;
  late final carousel.CarouselSliderController carouselController;

  bool _isAllLoaded = false;
  bool _isLoading = false;

  List<StoryListItem> _storyListItemList = [];

  final interstitialAdController = Get.find<InterstitialAdController>();
  final TextScaleFactorController textScaleFactorController = Get.find();

  @override
  void initState() {
    super.initState();
    _storySlug = widget.slug;
    carouselController = carousel.CarouselSliderController();
    _fetchTopicStoryList();
    interstitialAdController.ramdomShowInterstitialAd();
  }

  void _fetchTopicStoryList() {
    context.read<TopicStoryListBloc>().add(FetchTopicStoryList(_storySlug));
  }

  void _fetchTopicStoryListMore() {
    if (!_isAllLoaded) {
      context.read<TopicStoryListBloc>().add(FetchTopicStoryListMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicStoryListBloc, TopicStoryListState>(
      builder: (context, state) {
        if (state.status == TopicStoryListStatus.error) {
          final error = state.error;
          print('TopicStoryListError: ${error.message}');
          if (error is NoInternetException) {
            return error.renderWidget(onPressed: () => _fetchTopicStoryList());
          }
          return error.renderWidget();
        }

        if (state.status == TopicStoryListStatus.loadingMoreFail) {
          _fetchTopicStoryListMore();
          return _buildBody();
        }

        if (state.status == TopicStoryListStatus.loaded) {
          if (state.topicStoryList == null) {
            return  TabContentNoResultWidget();
          }

          _topicStoryList = state.topicStoryList!;
          if (_topicStoryList.storyListItemList != null) {
            _storyListItemList = _topicStoryList.storyListItemList!;
          }

          if (_storyListItemList.isEmpty) {
            return  TabContentNoResultWidget();
          }

          if (_storyListItemList.length == _topicStoryList.allStoryCount) {
            _isAllLoaded = true;
          }

          _isLoading = false;
          return _buildBody();
        }

        return const Center(child: CircularProgressIndicator.adaptive());
      },
    );
  }

  Widget _buildBody() {
    final width = MediaQuery.of(context).size.width;
    final height = width / 16 * 9;

    final firstFour = _storyListItemList.take(4).toList();
    final fiveToEight = _storyListItemList.skip(4).take(4).toList();
    final others = _storyListItemList.skip(8).toList();

    return ListView(
      children: [
        InlineBannerAdWidget(
          adUnitId: AdUnitIdHelper.getBannerAdUnitId('TopicHD'),
          sizes: [AdSize.mediumRectangle, AdSize(width: 336, height: 280)],
          wantKeepAlive: true,
        ),
        _buildLeading(width, height),
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

  Widget _buildLeading(double width, double height) {
    if (_topicStoryList.leading == 'slideshow' &&
        _topicStoryList.headerArticles != null &&
        _topicStoryList.headerArticles!.isNotEmpty) {
      final items = _topicStoryList.headerArticles!.map((item) {
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

    if (_topicStoryList.leading == 'video' && _topicStoryList.headerVideo != null) {
      final videoUrl = _topicStoryList.headerVideo!.url;
      if (videoUrl.contains('youtube')) {
        final videoId = VideoId.parseVideoId(videoUrl);
        return videoId == null
            ? const SizedBox()
            : YoutubePlayer(videoId, mute: true, autoPlay: true);
      } else {
        return MNewsVideoPlayer(
          videourl: videoUrl,
          aspectRatio: 16 / 9,
          autoPlay: true,
          muted: true,
        );
      }
    }

    if (_topicStoryList.leading == 'multivideo' &&
        _topicStoryList.headerVideoList != null &&
        _topicStoryList.headerVideoList!.isNotEmpty) {
      final items = _topicStoryList.headerVideoList!.map((item) {
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
                    const Icon(Icons.arrow_back_ios, color: themeColor, size: 18),
                    const SizedBox(width: 13),
                    Obx(() => Text(
                      '上一則影片',
                      style: const TextStyle(color: themeColor, fontSize: 14),
                      textScaleFactor:
                      textScaleFactorController.textScaleFactor.value,
                    )),
                  ],
                ),
              ),
              InkWell(
                onTap: () => carouselController.nextPage(),
                child: Row(
                  children: [
                    Obx(() => Text(
                      '下一則影片',
                      style: const TextStyle(color: themeColor, fontSize: 14),
                      textScaleFactor:
                      textScaleFactorController.textScaleFactor.value,
                    )),
                    const SizedBox(width: 13),
                    const Icon(Icons.arrow_forward_ios, color: themeColor, size: 18),
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
        imageUrl: _topicStoryList.photoUrl,
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
              Obx(() => Text(
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
              )),
              if (item.categoryList != null && item.categoryList!.isNotEmpty)
                Container(
                  color: const Color.fromRGBO(151, 151, 151, 1),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  width: 50,
                  alignment: Alignment.center,
                  child: Obx(() => Text(
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
                  )),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _loadMoreWidget() {
    if (_isAllLoaded) return const SizedBox(height: 28);

    return VisibilityDetector(
      key: const Key('TopicStoryListLoadingMore'),
      onVisibilityChanged: (info) {
        final percent = info.visibleFraction * 100;
        if (percent > 30 && !_isLoading) {
          _fetchTopicStoryListMore();
          _isLoading = true;
        }
      },
      child: const Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
