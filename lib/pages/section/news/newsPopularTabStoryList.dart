import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/tabStoryList/bloc.dart';
import 'package:tv/blocs/tabStoryList/events.dart';
import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/helpers/adHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/pages/section/news/shared/newsStoryFirstItem.dart';
import 'package:tv/pages/section/news/shared/newsStoryListItem.dart';
import 'package:tv/pages/shared/tabContentNoResultWidget.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';

class NewsPopularTabStoryList extends StatefulWidget {
  @override
  _NewsPopularTabStoryListState createState() => _NewsPopularTabStoryListState();
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
        if (state is TabStoryListError) {
          final error = state.error;
          print('NewsPopularTabStoryListError: ${error.message}');
          if( error is NoInternetException) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return error.renderWidget(
                    onPressed: () => _fetchPopularStoryList(),
                    isColumn: true
                  );
                },
                childCount: 1,
              ),
            );
          } 
          
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return error.renderWidget(
                  isNoButton: true,
                  isColumn: true
                );
              },
              childCount: 1,
            ),
          );
        }
        if (state is TabStoryListLoaded) {
          StoryListItemList storyListItemList = state.storyListItemList;

          if(storyListItemList.length == 0) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return TabContentNoResultWidget();
                },
                childCount: 1,
              ),
            );
          }

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
      }
    );
  }

  Widget _tabStoryList({
    required StoryListItemList storyListItemList,
  }) {
    List<Widget> _storyListWithAd = [];
    int _howManyAds = 0;
    int _whichAd = 1;
    for(int i = 0; i < storyListItemList.length; i++) {
      if (i % 6 == 1) {
        _howManyAds++;
        if(_whichAd == 1){
          _storyListWithAd.add(InlineBannerAdWidget(adUnitId: adHelper!.homeAT1AdUnitId));
          _whichAd++;
        }
        else if(_whichAd == 2){
          _storyListWithAd.add(InlineBannerAdWidget(adUnitId: adHelper!.homeAT2AdUnitId));
          _whichAd++;
        }
        else{
          _storyListWithAd.add(InlineBannerAdWidget(adUnitId: adHelper!.homeAT3AdUnitId));
          _whichAd = 1;
        }
      }
      else if (i == 0) {
        _storyListWithAd.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: NewsStoryFirstItem(storyListItem: storyListItemList[i]),
            )
        );
      }
      else {
        _storyListWithAd.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: NewsStoryListItem(
                  storyListItem: storyListItemList[i - _howManyAds]),
            )
        );
      }
    }
    if(storyListItemList.length == 1){
      _storyListWithAd.add(InlineBannerAdWidget(adUnitId: adHelper!.homeAT1AdUnitId));
      _howManyAds++;
    }
    else if(storyListItemList.length == 6){
      _storyListWithAd.add(InlineBannerAdWidget(adUnitId: adHelper!.homeAT2AdUnitId));
      _howManyAds++;
    }
    else if(storyListItemList.length == 11){
      _storyListWithAd.add(InlineBannerAdWidget(adUnitId: adHelper!.homeAT3AdUnitId));
      _howManyAds++;
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) => _storyListWithAd[index],
        childCount: _storyListWithAd.length
      ),
    );
  }
}