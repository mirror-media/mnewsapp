import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/tabStoryList/bloc.dart';
import 'package:tv/blocs/tabStoryList/events.dart';
import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/category.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/pages/section/news/shared/newsStoryFirstItem.dart';
import 'package:tv/pages/section/news/shared/newsStoryListItem.dart';
import 'package:tv/pages/shared/tabContentNoResultWidget.dart';

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
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if(!isLoading && 
          index == storyListItemList.length - 5 && 
          storyListItemList.length < storyListItemList.allStoryCount) {
            if(Category.checkIsLatestCategoryBySlug(widget.categorySlug)) {
              _fetchNextPage();
            } else {
              _fetchNextPageByCategorySlug();
            }
          }

          if (index == 0 && !needCarousel) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: NewsStoryFirstItem(storyListItem: storyListItemList[index]),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: NewsStoryListItem(storyListItem: storyListItemList[index]),
              ),
              if(index == storyListItemList.length - 1 && isLoading)
                _loadMoreWidget(),
            ],
          );
        },
        childCount: storyListItemList.length
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