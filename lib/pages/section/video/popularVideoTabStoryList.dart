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

class PopularVideoTabStoryList extends StatefulWidget {
  @override
  _PopularVideoTabStoryListState createState() =>
      _PopularVideoTabStoryListState();
}

class _PopularVideoTabStoryListState extends State<PopularVideoTabStoryList> {
  @override
  void initState() {
    _fetchPopularStoryList();
    super.initState();
  }

  _fetchPopularStoryList() async {
    context.read<TabStoryListBloc>().add(FetchPopularStoryList(isVideo: true));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabStoryListBloc, TabStoryListState>(
        builder: (BuildContext context, TabStoryListState state) {
      if (state.status == TabStoryListStatus.error) {
        final error = state.errorMessages;
        print('PopularVideoTabStoryListError: ${error.message}');
        if (error is NoInternetException) {
          return error.renderWidget(
              onPressed: () => _fetchPopularStoryList(), isColumn: true);
        }

        return TabContentNoResultWidget();
      }
      if (state.status == TabStoryListStatus.loaded) {
        List<StoryListItem> storyListItemList = state.storyListItemList!;

        if (storyListItemList.length == 0) {
          return TabContentNoResultWidget();
        }

        return _buildBody(
          storyListItemList: storyListItemList,
        );
      }

      // state is Init, loading, or other
      return Center(child: CircularProgressIndicator.adaptive());
    });
  }

  Widget _buildBody({
    required List<StoryListItem> storyListItemList,
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
}
