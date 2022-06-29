import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/blocs/tabStoryList/bloc.dart';
import 'package:tv/blocs/tabStoryList/events.dart';
import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/category.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/pages/section/news/shared/newsStoryFirstItem.dart';
import 'package:tv/pages/section/news/shared/newsStoryListItem.dart';
import 'package:tv/pages/shared/tabContentNoResultWidget.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';
import 'package:visibility_detector/visibility_detector.dart';

class NewsTabStoryList extends StatefulWidget {
  final String categorySlug;
  final bool needCarousel;
  NewsTabStoryList({required this.categorySlug, this.needCarousel = false});

  @override
  _NewsTabStoryListState createState() => _NewsTabStoryListState();
}

class _NewsTabStoryListState extends State<NewsTabStoryList> {
  int _allStoryCount = 0;

  @override
  void initState() {
    if (!context.read<TabStoryListBloc>().isClosed) {
      if (Category.checkIsLatestCategoryBySlug(widget.categorySlug)) {
        _fetchStoryList();
      } else {
        _fetchStoryListByCategorySlug();
      }
    }

    super.initState();
  }

  _fetchStoryList() async {
    context.read<TabStoryListBloc>().add(FetchStoryList());
  }

  _fetchNextPage() async {
    context.read<TabStoryListBloc>().add(FetchNextPage());
  }

  _fetchStoryListByCategorySlug() async {
    context
        .read<TabStoryListBloc>()
        .add(FetchStoryListByCategorySlug(widget.categorySlug));
  }

  _fetchNextPageByCategorySlug() async {
    context
        .read<TabStoryListBloc>()
        .add(FetchNextPageByCategorySlug(widget.categorySlug));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabStoryListBloc, TabStoryListState>(
        builder: (BuildContext context, TabStoryListState state) {
      if (state.status == TabStoryListStatus.error) {
        final error = state.errorMessages;
        print('TabStoryListError: ${error.message}');
        if (error is NoInternetException) {
          return error.renderWidget(
              onPressed: () {
                if (Category.checkIsLatestCategoryBySlug(widget.categorySlug)) {
                  _fetchStoryList();
                } else {
                  _fetchStoryListByCategorySlug();
                }
              },
              isColumn: true);
        }

        return error.renderWidget(isNoButton: true, isColumn: true);
      }
      if (state.status == TabStoryListStatus.loaded) {
        List<StoryListItem> storyListItemList = state.storyListItemList!;
        _allStoryCount = state.allStoryCount!;

        if (storyListItemList.length == 0) {
          return TabContentNoResultWidget();
        }

        return _tabStoryList(
          storyListItemList: storyListItemList,
          needCarousel: widget.needCarousel,
        );
      }

      if (state.status == TabStoryListStatus.loadingMore) {
        List<StoryListItem> storyListItemList = state.storyListItemList!;
        return _tabStoryList(
          storyListItemList: storyListItemList,
          needCarousel: widget.needCarousel,
          isLoading: true,
        );
      }

      if (state.status == TabStoryListStatus.loadingMoreError) {
        List<StoryListItem> storyListItemList = state.storyListItemList!;
        if (Category.checkIsLatestCategoryBySlug(widget.categorySlug)) {
          _fetchNextPage();
        } else {
          _fetchNextPageByCategorySlug();
        }
        return _tabStoryList(
            storyListItemList: storyListItemList,
            needCarousel: widget.needCarousel,
            isLoading: true);
      }

      // state is Init, loading, or other
      return Center(child: CircularProgressIndicator.adaptive());
    });
  }

  Widget _tabStoryList({
    required List<StoryListItem> storyListItemList,
    bool needCarousel = false,
    bool isLoading = false,
  }) {
    int itemCount = storyListItemList.length + 2;

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == itemCount - 1) {
          if (storyListItemList.length >= _allStoryCount) {
            return Container();
          }

          return VisibilityDetector(
            key: Key('TabStoryListLoadingMore'),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage > 30 && !isLoading) {
                if (Category.checkIsLatestCategoryBySlug(widget.categorySlug)) {
                  _fetchNextPage();
                } else {
                  _fetchNextPageByCategorySlug();
                }
              }
            },
            child: _loadMoreWidget(),
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
        return const SizedBox(
          height: 16,
        );
      },
      itemCount: itemCount,
    );
  }

  Widget _loadMoreWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
