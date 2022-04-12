import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/tabStoryList/bloc.dart';
import 'package:tv/blocs/tabStoryList/events.dart';
import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/pages/section/video/shared/videoStoryListItem.dart';
import 'package:tv/pages/shared/tabContentNoResultWidget.dart';

class PopularVideoTabStoryList extends StatefulWidget {
  @override
  _PopularVideoTabStoryListState createState() =>
      _PopularVideoTabStoryListState();
}

class _PopularVideoTabStoryListState extends State<PopularVideoTabStoryList> {
  // late AdUnitId _adUnitId;
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
      if (state.status == TabStoryListStatus.loaded) {
        List<StoryListItem> storyListItemList = state.storyListItemList!;

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

        // if (state.adUnitId != null) _adUnitId = state.adUnitId!;

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
    required List<StoryListItem> storyListItemList,
  }) {
    List<Widget> _storyListWithAd = [];
    // List<String?> _adPositions = [
    //   _adUnitId.at1AdUnitId,
    //   _adUnitId.at2AdUnitId,
    //   _adUnitId.at3AdUnitId
    // ];
    int _howManyAds = 0;
    // int _adCounter = 0;
    for (int i = 0; i < storyListItemList.length; i++) {
      // if (i % 4 == 1) {
      //   _storyListWithAd.add(
      //     InlineBannerAdWidget(
      //       adUnitId: _adPositions[_adCounter],
      //     ),
      //   );
      //   _howManyAds++;
      //   _adCounter++;
      //   if (_adCounter == 3) _adCounter = 0;
      // } else {
      _storyListWithAd.add(Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: VideoStoryListItem(
            storyListItem: storyListItemList[i - _howManyAds]),
      ));
      // }
    }
    // if (storyListItemList.length == 1) {
    //   _storyListWithAd.add(InlineBannerAdWidget(adUnitId: _adUnitId.at1AdUnitId),);
    //   _howManyAds++;
    // }
    // else if (storyListItemList.length == 5) {
    //   _storyListWithAd.add(InlineBannerAdWidget(adUnitId: _adUnitId.at2AdUnitId),);
    //   _howManyAds++;
    // }
    // else if (storyListItemList.length == 8) {
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
