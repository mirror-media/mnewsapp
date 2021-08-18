import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/tabStoryList/bloc.dart';
import 'package:tv/blocs/tabStoryList/events.dart';
import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/helpers/adHelper.dart';
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
          );
        }

        if (state is TabStoryListLoadingMore) {
          StoryListItemList storyListItemList = state.storyListItemList;
          return _tabStoryList(
            storyListItemList: storyListItemList, 
            needCarousel: widget.needCarousel,
            isLoading: true
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
            isLoading: true
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
    bool needCarousel = false, bool isLoading = false
  }) {
    List<Widget> _storyListWithAd = [];
    int _howManyAds = 0;
    int _whichAd = 1;
    late String _adUnitId1;
    late String _adUnitId2;
    late String _adUnitId3;
    switch (widget.categorySlug){
      case 'ent':
      case 'entertainment':
        _adUnitId1 = adHelper!.entAT1AdUnitId;
        _adUnitId2 = adHelper!.entAT2AdUnitId;
        _adUnitId3 = adHelper!.entAT3AdUnitId;
        break;
      case 'unc':
        _adUnitId1 = adHelper!.uncAT1AdUnitId;
        _adUnitId2 = adHelper!.uncAT2AdUnitId;
        _adUnitId3 = adHelper!.uncAT3AdUnitId;
        break;
      case 'lif':
      case 'life':
        _adUnitId1 = adHelper!.lifAT1AdUnitId;
        _adUnitId2 = adHelper!.lifAT2AdUnitId;
        _adUnitId3 = adHelper!.lifAT3AdUnitId;
        break;
      case 'soc':
      case 'society':
        _adUnitId1 = adHelper!.socAT1AdUnitId;
        _adUnitId2 = adHelper!.socAT2AdUnitId;
        _adUnitId3 = adHelper!.socAT3AdUnitId;
        break;
      case 'fin':
      case 'financial':
      case 'finance':
        _adUnitId1 = adHelper!.finAT1AdUnitId;
        _adUnitId2 = adHelper!.finAT2AdUnitId;
        _adUnitId3 = adHelper!.finAT3AdUnitId;
        break;
      case 'int':
      case 'international':
        _adUnitId1 = adHelper!.intAT1AdUnitId;
        _adUnitId2 = adHelper!.intAT2AdUnitId;
        _adUnitId3 = adHelper!.intAT3AdUnitId;
        break;
      case 'pol':
      case 'politic':
        _adUnitId1 = adHelper!.polAT1AdUnitId;
        _adUnitId2 = adHelper!.polAT2AdUnitId;
        _adUnitId3 = adHelper!.polAT3AdUnitId;
        break;
      default:
        _adUnitId1 = adHelper!.homeAT1AdUnitId;
        _adUnitId2 = adHelper!.homeAT2AdUnitId;
        _adUnitId3 = adHelper!.homeAT3AdUnitId;
    }
    if(!needCarousel){
      for(int i = 0; i < storyListItemList.length; i++) {
        if (i % 6 == 1) {
          if(_whichAd == 1){
            _storyListWithAd.add(InlineBannerAdWidget(adUnitId: _adUnitId1));
            _whichAd++;
          }
          else if(_whichAd == 2){
            _storyListWithAd.add(InlineBannerAdWidget(adUnitId: _adUnitId2));
            _whichAd++;
          }
          else{
            _storyListWithAd.add(InlineBannerAdWidget(adUnitId: _adUnitId3));
            _whichAd = 1;
          }
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
      if(storyListItemList.length == 1){
        _storyListWithAd.add(InlineBannerAdWidget(adUnitId: _adUnitId1));
        _howManyAds++;
      }
      else if(storyListItemList.length == 6){
        _storyListWithAd.add(InlineBannerAdWidget(adUnitId: _adUnitId2));
        _howManyAds++;
      }
      else if(storyListItemList.length == 11){
        _storyListWithAd.add(InlineBannerAdWidget(adUnitId: _adUnitId3));
        _howManyAds++;
      }
    }
    else{
      for(int i = 0; i < storyListItemList.length; i++){
        if(i % 6 == 0){
          if(_whichAd == 1){
            _storyListWithAd.add(InlineBannerAdWidget(adUnitId: _adUnitId1));
            _whichAd++;
          }
          else if(_whichAd == 2){
            _storyListWithAd.add(InlineBannerAdWidget(adUnitId: _adUnitId2));
            _whichAd++;
          }
          else{
            _storyListWithAd.add(InlineBannerAdWidget(adUnitId: _adUnitId3));
            _whichAd = 1;
          }
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
      if(storyListItemList.length == 1){
        _storyListWithAd.add(InlineBannerAdWidget(adUnitId: _adUnitId1));
        _howManyAds++;
      }
      else if(storyListItemList.length == 7){
        _storyListWithAd.add(InlineBannerAdWidget(adUnitId: _adUnitId2));
        _howManyAds++;
      }
      else if(storyListItemList.length == 12){
        _storyListWithAd.add(InlineBannerAdWidget(adUnitId: _adUnitId3));
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