import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/blocs/topicStoryList/bloc.dart';
import 'package:tv/controller/interstitialAdController.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/models/topicStoryList.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/pages/shared/editorChoice/carouselDisplayWidget.dart';
import 'package:tv/pages/shared/tabContentNoResultWidget.dart';
import 'package:tv/pages/storyPage.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';
import 'package:tv/widgets/story/mNewsVideoPlayer.dart';
import 'package:tv/widgets/story/youtubePlayer.dart';
import 'package:tv/widgets/story/youtubeViewer.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class TopicStoryListWidget extends StatefulWidget {
  final String slug;
  TopicStoryListWidget(this.slug);
  @override
  _TopicStoryListWidgetState createState() => _TopicStoryListWidgetState();
}

class _TopicStoryListWidgetState extends State<TopicStoryListWidget> {
  late TopicStoryList _topicStoryList;
  late final _storySlug;
  bool _isAllLoaded = false;
  List<StoryListItem> _storyListItemList = [];
  CarouselController carouselController = CarouselController();
  bool _isLoading = false;
  final interstitialAdController = Get.find<InterstitialAdController>();
  final TextScaleFactorController textScaleFactorController = Get.find();

  @override
  void initState() {
    _storySlug = widget.slug;
    _fetchTopicStoryList();
    interstitialAdController.ramdomShowInterstitialAd();
    super.initState();
  }

  _fetchTopicStoryList() {
    context.read<TopicStoryListBloc>().add(FetchTopicStoryList(_storySlug));
  }

  _fetchTopicStoryListMore() {
    if (!_isAllLoaded) {
      context.read<TopicStoryListBloc>().add(FetchTopicStoryListMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicStoryListBloc, TopicStoryListState>(
      builder: (BuildContext context, TopicStoryListState state) {
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
            return TabContentNoResultWidget();
          }
          _topicStoryList = state.topicStoryList!;

          if (_topicStoryList.storyListItemList != null) {
            _storyListItemList = _topicStoryList.storyListItemList!;
          }

          if (_storyListItemList.isEmpty) {
            return TabContentNoResultWidget();
          }

          if (_storyListItemList.length == _topicStoryList.allStoryCount) {
            _isAllLoaded = true;
          }

          _isLoading = false;

          return _buildBody();
        }

        return Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  Widget _buildBody() {
    double width = MediaQuery.of(context).size.width;
    double height = width / 16 * 9;
    List<StoryListItem> firstFour = [];
    List<StoryListItem> fiveToEight = [];
    List<StoryListItem> others = [];
    for (int i = 0; i < _storyListItemList.length; i++) {
      if (i < 4) {
        firstFour.add(_storyListItemList[i]);
      } else if (i < 8) {
        fiveToEight.add(_storyListItemList[i]);
      } else {
        others.add(_storyListItemList[i]);
      }
    }
    return ListView(
      children: [
        InlineBannerAdWidget(
          adUnitId: AdUnitIdHelper.getBannerAdUnitId('TopicHD'),
          sizes: [
            AdSize.mediumRectangle,
            AdSize(width: 336, height: 280),
          ],
          wantKeepAlive: true,
        ),
        _buildLeading(width, height),
        const SizedBox(
          height: 16,
        ),
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
          sizes: [
            AdSize.mediumRectangle,
            AdSize(width: 336, height: 280),
          ],
          wantKeepAlive: true,
        ),
        _buildTopicStoryList(others),
        _loadMoreWidget(),
      ],
    );
  }

  Widget _buildTopicStoryList(List<StoryListItem> storyListItemList) {
    return ListView.separated(
      itemCount: storyListItemList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) {
        return const Divider(
          height: 16,
          thickness: 1,
          color: Color.fromRGBO(244, 245, 246, 1),
          indent: 24,
          endIndent: 27,
        );
      },
      itemBuilder: (context, index) {
        return InkWell(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: _buildTopicStoryListItem(storyListItemList[index]),
          ),
          onTap: () {
            Get.to(() => StoryPage(
                  slug: storyListItemList[index].slug,
                ));
          },
        );
      },
    );
  }

  Widget _buildLeading(double width, double height) {
    if (_topicStoryList.leading == 'slideshow' &&
        _topicStoryList.headerArticles != null &&
        _topicStoryList.headerArticles!.isNotEmpty) {
      List<Widget> items = [];
      var width = MediaQuery.of(context).size.width;
      var height = width / (16 / 9);
      if (height > 700) {
        height = 700;
      } else if (height > 500) {
        height = (height ~/ 100) * 100;
      }
      height = height + 120;
      for (var item in _topicStoryList.headerArticles!) {
        items.add(CarouselDisplayWidget(
          storyListItem: item,
          width: width,
          isHomePage: false,
          showTag: false,
        ));
      }
      return CarouselSlider(
        items: items,
        options: CarouselOptions(
          autoPlay: true,
          aspectRatio: 2.0,
          viewportFraction: 1.0,
          height: height,
        ),
      );
    } else if (_topicStoryList.leading == 'video' &&
        _topicStoryList.headerVideo != null) {
      if (_topicStoryList.headerVideo!.url.contains('youtube')) {
        String? videoId =
            VideoId.parseVideoId(_topicStoryList.headerVideo!.url);
        if (videoId == null) {
          return Container();
        } else {
          return YoutubePlayer(
            videoId,
            mute: true,
            autoPlay: true,
          );
        }
      } else {
        return MNewsVideoPlayer(
          videourl: _topicStoryList.headerVideo!.url,
          aspectRatio: 16 / 9,
          autoPlay: true,
          muted: true,
        );
      }
    } else if (_topicStoryList.leading == 'multivideo' &&
        _topicStoryList.headerVideoList != null &&
        _topicStoryList.headerVideoList!.isNotEmpty) {
      List<Widget> items = [];
      for (var item in _topicStoryList.headerVideoList!) {
        String? videoId = VideoId.parseVideoId(item.url);
        if (videoId != null) {
          items.add(YoutubeViewer(
            videoId,
            autoPlay: true,
            mute: true,
          ));
        }
      }
      if (items.isEmpty) {
        return Container();
      }
      return Column(
        children: [
          CarouselSlider(
            items: items,
            carouselController: carouselController,
            options: CarouselOptions(
              autoPlay: false,
              aspectRatio: 2.0,
              viewportFraction: 1.0,
              height: MediaQuery.of(context).size.width / (16 / 9),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  carouselController.previousPage();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 8,
                    ),
                    Icon(
                      Icons.arrow_back_ios,
                      color: themeColor,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 13,
                    ),
                    Obx(
                      () => Text(
                        '上一則影片',
                        style: TextStyle(color: themeColor, fontSize: 14),
                        textScaleFactor:
                            textScaleFactorController.textScaleFactor.value,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  carouselController.nextPage();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Obx(
                      () => Text(
                        '下一則影片',
                        style: TextStyle(color: themeColor, fontSize: 14),
                        textScaleFactor:
                            textScaleFactorController.textScaleFactor.value,
                      ),
                    ),
                    const SizedBox(
                      width: 13,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: themeColor,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 29),
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
          child: Icon(Icons.error),
        ),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTopicStoryListItem(StoryListItem storyListItem) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2.0),
          child: SizedBox(
            width: 90,
            height: 90,
            child: CachedNetworkImage(
              width: 90,
              height: 90,
              imageUrl: storyListItem.photoUrl,
              placeholder: (context, url) => Container(
                height: 90,
                width: 90,
                color: Colors.grey,
              ),
              errorWidget: (context, url, error) => Container(
                height: 90,
                width: 90,
                color: Colors.grey,
                child: Icon(Icons.error),
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        SizedBox(
          height: 90,
          width: MediaQuery.of(context).size.width - 90 - 12 - 48,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  storyListItem.name,
                  softWrap: true,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textScaleFactor:
                      textScaleFactorController.textScaleFactor.value,
                ),
              ),
              if (storyListItem.categoryList != null &&
                  storyListItem.categoryList!.isNotEmpty)
                Container(
                  color: const Color.fromRGBO(151, 151, 151, 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  width: 50,
                  alignment: Alignment.center,
                  child: Obx(
                    () => Text(
                      storyListItem.categoryList![0].name,
                      softWrap: true,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor:
                          textScaleFactorController.textScaleFactor.value,
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
    if (_isAllLoaded) {
      return SizedBox(
        height: 28,
      );
    }

    return VisibilityDetector(
      key: Key('TopicStoryListLoadingMore'),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage > 30 && !_isLoading) {
          _fetchTopicStoryListMore();
          _isLoading = true;
        }
      },
      child: Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
