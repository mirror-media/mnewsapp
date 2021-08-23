import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/blocs/tabStoryList/bloc.dart';
import 'package:tv/blocs/tabStoryList/events.dart';
import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/category.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/pages/section/news/shared/newsStoryFirstItem.dart';
import 'package:tv/pages/section/news/shared/newsStoryListItem.dart';
import 'package:tv/pages/shared/tabContentNoResultWidget.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';

class NewsTabStoryList extends StatefulWidget {
  final String categorySlug;
  final bool needCarousel;
  NewsTabStoryList({
    required this.categorySlug,
    this.needCarousel = false
  });

  @override
  _NewsTabStoryListState createState() => _NewsTabStoryListState();
}

class _NewsTabStoryListState extends State<NewsTabStoryList> {
  @override
  void initState() {
    if(Category.checkIsLatestCategoryBySlug(widget.categorySlug)) {
      _fetchStoryList();
    } else {
      _fetchStoryListByCategorySlug();
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
                    onPressed: () {
                      if(Category.checkIsLatestCategoryBySlug(widget.categorySlug)) {
                        _fetchStoryList();
                      } else {
                        _fetchStoryListByCategorySlug();
                      }
                    },
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
            needCarousel: widget.needCarousel,
            bannerAdList: bannerAdList,
          );
        }

        if (state is TabStoryListLoadingMore) {
          StoryListItemList storyListItemList = state.storyListItemList;
          return _tabStoryList(
            storyListItemList: storyListItemList, 
            needCarousel: widget.needCarousel,
            isLoading: true,
          );
        }

        if(state is TabStoryListLoadingMoreFail) {
          StoryListItemList storyListItemList = state.storyListItemList;
          if(Category.checkIsLatestCategoryBySlug(widget.categorySlug)) {
            _fetchNextPage();
          } else {
            _fetchNextPageByCategorySlug();
          }
          return _tabStoryList(
            storyListItemList: storyListItemList, 
            needCarousel: widget.needCarousel,
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
    bool needCarousel = false, bool isLoading = false,
    List<BannerAd>? bannerAdList
  }) {
    List<Widget> _storyListWithAd = [];
    int _howManyAds = 0;
    int _whichAd = 0;
    if(!needCarousel){
      for(int i = 0; i < storyListItemList.length; i++) {
        if (i % 6 == 1 && bannerAdList != null) {
          _storyListWithAd.add(InlineBannerAdWidget(bannerAd: bannerAdList[_whichAd],));
          _whichAd++;
          if(_whichAd == 3)
            _whichAd = 0;
          _howManyAds++;
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
      if(storyListItemList.length == 1 && bannerAdList != null){
        _storyListWithAd.add(InlineBannerAdWidget(bannerAd: bannerAdList[0],));
        _howManyAds++;
      }
      else if(storyListItemList.length == 6 && bannerAdList != null){
        _storyListWithAd.add(InlineBannerAdWidget(bannerAd: bannerAdList[1],));
        _howManyAds++;
      }
      else if(storyListItemList.length == 11 && bannerAdList != null){
        _storyListWithAd.add(InlineBannerAdWidget(bannerAd: bannerAdList[2],));
        _howManyAds++;
      }
    }
    else{
      for(int i = 0; i < storyListItemList.length; i++){
        if(i % 6 == 0 && bannerAdList != null){
          _storyListWithAd.add(InlineBannerAdWidget(bannerAd: bannerAdList[_whichAd],));
          _whichAd++;
          if(_whichAd == 3)
            _whichAd = 0;
          _howManyAds++;
        }
        else{
          _storyListWithAd.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: NewsStoryListItem(storyListItem: storyListItemList[i - _howManyAds]),
              )
          );
        }
      }
      if(storyListItemList.length == 1 && bannerAdList != null){
        _storyListWithAd.add(InlineBannerAdWidget(bannerAd: bannerAdList[0],));
        _howManyAds++;
      }
      else if(storyListItemList.length == 7 && bannerAdList != null){
        _storyListWithAd.add(InlineBannerAdWidget(bannerAd: bannerAdList[1],));
        _howManyAds++;
      }
      else if(storyListItemList.length == 12 && bannerAdList != null){
        _storyListWithAd.add(InlineBannerAdWidget(bannerAd: bannerAdList[2],));
        _howManyAds++;
      }
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if(!isLoading && 
          index == _storyListWithAd.length - 5 &&
              storyListItemList.length < storyListItemList.allStoryCount) {
            if(Category.checkIsLatestCategoryBySlug(widget.categorySlug)) {
              _fetchNextPage();
            } else {
              _fetchNextPageByCategorySlug();
            }
          }

          return Column(
            children: [
              _storyListWithAd[index],
              if(index == _storyListWithAd.length - 1 && isLoading)
                _loadMoreWidget(),
            ],
          );
        },
        childCount: _storyListWithAd.length,
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