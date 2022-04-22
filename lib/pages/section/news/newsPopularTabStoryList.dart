import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/blocs/tabStoryList/bloc.dart';
import 'package:tv/blocs/tabStoryList/events.dart';
import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItem.dart';
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
      if (state.status == TabStoryListStatus.error) {
        final error = state.errorMessages;
        print('NewsPopularTabStoryListError: ${error.message}');
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

        return _tabStoryList(
          storyListItemList: storyListItemList,
        );
      }

      // state is Init, loading, or other
      return Center(child: CircularProgressIndicator.adaptive());
    });
  }

  Widget _tabStoryList({
    required List<StoryListItem> storyListItemList,
  }) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index == 0) {
          return NewsStoryFirstItem(
            storyListItem: storyListItemList[0],
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

        return NewsStoryListItem(
          storyListItem: storyListItemList[index - 1],
        );
      },
      separatorBuilder: (context, index) {
        if (index == 6) {
          return InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('NewsAT2'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
            ],
          );
        } else if (index == 11) {
          return InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('NewsAT3'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
            ],
          );
        }
        return const SizedBox(
          height: 16,
        );
      },
      itemCount: storyListItemList.length + 1,
    );
  }
}
