import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/blocs/tabStoryList/bloc.dart';
import 'package:tv/blocs/tabStoryList/events.dart';
import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/pages/section/video/shared/videoStoryListItem.dart';
import 'package:tv/pages/shared/tabContentNoResultWidget.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';

class VideoTabStoryList extends StatefulWidget {
  final String categorySlug;
  VideoTabStoryList({
    required this.categorySlug,
  });

  @override
  _VideoTabStoryListState createState() => _VideoTabStoryListState();
}

class _VideoTabStoryListState extends State<VideoTabStoryList> {
  @override
  void initState() {
    _fetchStoryListByCategorySlug();
    super.initState();
  }

  _fetchStoryListByCategorySlug() async {
    context.read<TabStoryListBloc>().add(FetchStoryListByCategorySlug(widget.categorySlug));
  }

  _fetchNextPageByCategorySlug() async {
    context.read<TabStoryListBloc>().add(FetchNextPageByCategorySlug(widget.categorySlug));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabStoryListBloc, TabStoryListState>(
      builder: (BuildContext context, TabStoryListState state) {
        if (state is TabStoryListError) {
          final error = state.error;
          print('TabStoryListError: ${error.message}');
          if( error is NoInternetException) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return error.renderWidget(
                    onPressed: () => _fetchStoryListByCategorySlug(),
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
          List<BannerAd>? bannerAdList = state.bannerAdList;

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
            bannerAdList: bannerAdList
          );
        }

        if (state is TabStoryListLoadingMore) {
          StoryListItemList storyListItemList = state.storyListItemList;
          return _tabStoryList(
            storyListItemList: storyListItemList, 
            isLoading: true,
          );
        }

        if(state is TabStoryListLoadingMoreFail) {
          StoryListItemList storyListItemList = state.storyListItemList;
          _fetchNextPageByCategorySlug();
          return _tabStoryList(
            storyListItemList: storyListItemList, 
            isLoading: true,
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
    bool isLoading = false,
    List<BannerAd>? bannerAdList
  }) {
    List<Widget> _storyListWithAd = [];
    int _howManyAds = 0;
    int _whichAd = 1;
    for(int i = 0; i < storyListItemList.length; i++) {
      if (i % 4 == 1 && bannerAdList != null) {
        _storyListWithAd.add(InlineBannerAdWidget(bannerAd: bannerAdList[_whichAd],));
        _whichAd++;
        if(_whichAd == 3)
          _whichAd = 0;
        _howManyAds++;
      }
      else {
        _storyListWithAd.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: VideoStoryListItem(
                  storyListItem: storyListItemList[i - _howManyAds]),
            )
        );
      }
    }
    if(storyListItemList.length == 1 && bannerAdList != null){
      _storyListWithAd.add(InlineBannerAdWidget(bannerAd: bannerAdList[0],));
      _howManyAds++;
    }
    else if(storyListItemList.length == 5 && bannerAdList != null){
      _storyListWithAd.add(InlineBannerAdWidget(bannerAd: bannerAdList[1],));
      _howManyAds++;
    }
    else if(storyListItemList.length == 8 && bannerAdList != null){
      _storyListWithAd.add(InlineBannerAdWidget(bannerAd: bannerAdList[2],));
      _howManyAds++;
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if(!isLoading && 
          index == storyListItemList.length - 5 && 
          storyListItemList.length < storyListItemList.allStoryCount) {
            _fetchNextPageByCategorySlug();
          }

          return Column(
            children: [
              _storyListWithAd[index],
              if(index == _storyListWithAd.length - 1 && isLoading)
                _loadMoreWidget(),
            ],
          );
        },
        childCount: _storyListWithAd.length
      ),
    );
  }

  Widget _loadMoreWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: CupertinoActivityIndicator()
      ),
    );
  }
}