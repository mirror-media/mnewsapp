import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:tv/blocs/topicStoryList/bloc.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/helpers/routeGenerator.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/models/topicStoryList.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/pages/shared/editorChoice/carouselDisplayWidget.dart';
import 'package:tv/pages/shared/tabContentNoResultWidget.dart';
import 'package:tv/widgets/story/mNewsVideoPlayer.dart';
import 'package:tv/widgets/story/youtubePlayer.dart';
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
  StoryListItemList _storyListItemList = StoryListItemList();

  @override
  void initState() {
    _storySlug = widget.slug;
    _fetchTopicStoryList();
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
          return _buildTopicStoryList();
        }

        if (state.status == TopicStoryListStatus.loaded) {
          if (state.topicStoryList == null) {
            return TabContentNoResultWidget();
          }
          _topicStoryList = state.topicStoryList!;

          if (_topicStoryList.storyListItemList != null) {
            _storyListItemList = _topicStoryList.storyListItemList!;
          }

          if (_storyListItemList.length == _storyListItemList.allStoryCount) {
            _isAllLoaded = true;
          }

          return _buildTopicStoryList();
        }

        return CircularProgressIndicator();
      },
    );
  }

  Widget _buildTopicStoryList() {
    double width = MediaQuery.of(context).size.width;
    double height = width / 16 * 9;

    if (_storyListItemList.isEmpty) {
      return Column(
        children: [
          _buildLeading(width, height),
          TabContentNoResultWidget(),
        ],
      );
    }

    return ListView.separated(
      itemCount: _storyListItemList.length + 2,
      padding: EdgeInsets.only(bottom: 28),
      separatorBuilder: (context, index) {
        if (index == 0 || index == _storyListItemList.length) {
          return const SizedBox(
            height: 16,
          );
        }
        return const Divider(
          height: 16,
          thickness: 1,
          color: Color.fromRGBO(244, 245, 246, 1),
          indent: 24,
          endIndent: 27,
        );
      },
      itemBuilder: (context, index) {
        if (index == _storyListItemList.length && !_isAllLoaded) {
          _fetchTopicStoryListMore();
        }

        if (index == 0) {
          return _buildLeading(width, height);
        }

        if (index == _storyListItemList.length + 1) {
          if (_isAllLoaded) {
            return Container();
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return InkWell(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: _buildTopicStoryListItem(_storyListItemList[index - 1]),
          ),
          onTap: () {
            RouteGenerator.navigateToStory(
                context, _storyListItemList[index - 1].slug);
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
          height: 350,
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
        _topicStoryList.headerVideoList!.isNotEmpty) {}

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
              Text(
                storyListItem.name,
                softWrap: true,
                maxLines: 2,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (storyListItem.categoryList != null &&
                  storyListItem.categoryList!.isNotEmpty)
                Container(
                  color: const Color.fromRGBO(151, 151, 151, 1),
                  padding: const EdgeInsets.only(left: 6, right: 6, bottom: 3),
                  child: Text(
                    storyListItem.categoryList![0].name,
                    softWrap: true,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
