import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/blocs/tabStoryList/bloc.dart';
import 'package:tv/blocs/tabStoryList/events.dart';
import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/pages/section/video/shared/videoStoryListItem.dart';
import 'package:tv/pages/shared/tabContentNoResultWidget.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoTabStoryList extends StatefulWidget {
  final String categorySlug;
  VideoTabStoryList({
    required this.categorySlug,
  });

  @override
  _VideoTabStoryListState createState() => _VideoTabStoryListState();
}

class _VideoTabStoryListState extends State<VideoTabStoryList> {
  int _allStoryCount = 0;

  @override
  void initState() {
    _fetchStoryListByCategorySlug();
    super.initState();
  }

  _fetchStoryListByCategorySlug() async {
    context
        .read<TabStoryListBloc>()
        .add(FetchStoryListByCategorySlug(widget.categorySlug, isVideo: true));
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
              onPressed: () => _fetchStoryListByCategorySlug(), isColumn: true);
        }

        return error.renderWidget(isNoButton: true, isColumn: true);
      }
      if (state.status == TabStoryListStatus.loaded) {
        List<StoryListItem> storyListItemList = state.storyListItemList!;
        _allStoryCount = state.allStoryCount!;

        if (storyListItemList.length == 0) {
          return TabContentNoResultWidget();
        }

        return _buildBody(
          storyListItemList: storyListItemList,
        );
      }

      if (state.status == TabStoryListStatus.loadingMore) {
        List<StoryListItem> storyListItemList = state.storyListItemList!;
        return _buildBody(
            storyListItemList: storyListItemList, isLoading: true);
      }

      if (state.status == TabStoryListStatus.loadingMoreError) {
        List<StoryListItem> storyListItemList = state.storyListItemList!;
        _fetchNextPageByCategorySlug();
        return _buildBody(
            storyListItemList: storyListItemList, isLoading: true);
      }

      // state is Init, loading, or other
      return Center(child: CircularProgressIndicator.adaptive());
    });
  }

  Widget _buildBody({
    required List<StoryListItem> storyListItemList,
    bool isLoading = false,
  }) {
    List<StoryListItem> twoToFour = [];
    List<StoryListItem> fiveToSeven = [];
    List<StoryListItem> others = [];
    for (int i = 1; i < storyListItemList.length; i++) {
      if (i < 4) {
        twoToFour.add(storyListItemList[i]);
      } else if (i < 7) {
        fiveToSeven.add(storyListItemList[i]);
      } else {
        others.add(storyListItemList[i]);
      }
    }
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        VideoStoryListItem(storyListItem: storyListItemList[0]),
        InlineBannerAdWidget(
          adUnitId: AdUnitIdHelper.getBannerAdUnitId('VideoAT1'),
          sizes: [
            AdSize.mediumRectangle,
            AdSize(width: 336, height: 280),
          ],
        ),
        _tabStoryList(storyListItemList: twoToFour),
        InlineBannerAdWidget(
          adUnitId: AdUnitIdHelper.getBannerAdUnitId('VideoAT2'),
          sizes: [
            AdSize.mediumRectangle,
            AdSize(width: 336, height: 280),
            AdSize(width: 320, height: 480),
          ],
        ),
        _tabStoryList(storyListItemList: fiveToSeven),
        InlineBannerAdWidget(
          adUnitId: AdUnitIdHelper.getBannerAdUnitId('VideoAT3'),
          sizes: [
            AdSize.mediumRectangle,
            AdSize(width: 336, height: 280),
          ],
        ),
        _tabStoryList(storyListItemList: others),
        _loadMoreWidget(storyListItemList.length >= _allStoryCount, isLoading),
      ],
    );
  }

  Widget _tabStoryList({
    required List<StoryListItem> storyListItemList,
  }) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return VideoStoryListItem(storyListItem: storyListItemList[index]);
      },
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: 24,
        );
      },
      itemCount: storyListItemList.length,
    );
  }

  Widget _loadMoreWidget(bool isAll, bool isLoading) {
    if (isAll) {
      return Container();
    }

    return VisibilityDetector(
      key: Key('VideoTabStoryListLoadingMore'),
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage > 30 && !isLoading) {
          _fetchNextPageByCategorySlug();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
