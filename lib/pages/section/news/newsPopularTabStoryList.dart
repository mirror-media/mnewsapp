import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/tabStoryList/bloc.dart';
import 'package:tv/blocs/tabStoryList/events.dart';
import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/adUnitId.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/pages/section/news/shared/newsStoryFirstItem.dart';
import 'package:tv/pages/section/news/shared/newsStoryListItem.dart';
import 'package:tv/pages/shared/tabContentNoResultWidget.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';

class NewsPopularTabStoryList extends StatefulWidget {
  @override
  _NewsPopularTabStoryListState createState() =>
      _NewsPopularTabStoryListState();
}

class _NewsPopularTabStoryListState extends State<NewsPopularTabStoryList> {
  late AdUnitId _adUnitId;
  @override
  void initState() {
    _fetchPopularStoryList();
    super.initState();
  }

  _fetchPopularStoryList() async {
    context.read<TabStoryListBloc>().add(FetchPopularStoryList());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabStoryListBloc, TabStoryListState>(
        builder: (BuildContext context, TabStoryListState state) {
      if (state is TabStoryListError) {
        final error = state.error;
        print('NewsPopularTabStoryListError: ${error.message}');
        if (error is NoInternetException) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return error.renderWidget(
                    onPressed: () => _fetchPopularStoryList(), isColumn: true);
              },
              childCount: 1,
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return TabContentNoResultWidget();
            },
            childCount: 1,
          ),
        );
      }
      if (state is TabStoryListLoaded) {
        StoryListItemList storyListItemList = state.storyListItemList;

        if (storyListItemList.length == 0) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return TabContentNoResultWidget();
              },
              childCount: 1,
            ),
          );
        }

        if (state.adUnitId != null) _adUnitId = state.adUnitId!;

        return _tabStoryList(
          storyListItemList: storyListItemList,
        );
      }

      // state is Init, loading, or other
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return Center(child: CupertinoActivityIndicator());
          },
          childCount: 1,
        ),
      );
    });
  }

  Widget _tabStoryList({
    required StoryListItemList storyListItemList,
  }) {
    List<Widget> _storyListWithAd = [];
    // List<String?> _adPositions = [_adUnitId.at1AdUnitId, _adUnitId.at2AdUnitId, _adUnitId.at3AdUnitId];
    int _howManyAds = 0;
    // int _adCounter = 0;
    for (int i = 0; i < storyListItemList.length; i++) {
      // if (i % 6 == 1) {
      //   _storyListWithAd.add(
      //     InlineBannerAdWidget(
      //       adUnitId: _adPositions[_adCounter],
      //     ),
      //   );
      //   _howManyAds++;
      //   _adCounter++;
      //   if (_adCounter == 3) _adCounter = 0;
      // } else
      if (i == 0) {
        _storyListWithAd.add(Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: NewsStoryFirstItem(storyListItem: storyListItemList[i]),
        ));
      } else {
        _storyListWithAd.add(Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: NewsStoryListItem(
              storyListItem: storyListItemList[i - _howManyAds]),
        ));
      }
    }
    // if (storyListItemList.length == 1) {
    //   _storyListWithAd.add(InlineBannerAdWidget(adUnitId: _adUnitId.at1AdUnitId));
    //   _howManyAds++;
    // }
    // else if (storyListItemList.length == 6) {
    //   _storyListWithAd.add(InlineBannerAdWidget(adUnitId: _adUnitId.at2AdUnitId),);
    //   _howManyAds++;
    // }
    // else if (storyListItemList.length == 11) {
    //   _storyListWithAd.add(InlineBannerAdWidget(adUnitId: _adUnitId.at3AdUnitId),);
    //   _howManyAds++;
    // }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) => _storyListWithAd[index],
          childCount: _storyListWithAd.length),
    );
  }
}
