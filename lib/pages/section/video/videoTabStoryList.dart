import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/tabStoryList/bloc.dart';
import 'package:tv/blocs/tabStoryList/events.dart';
import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/pages/section/video/shared/videoStoryListItem.dart';

class VideoTabStoryList extends StatefulWidget {
  final String categorySlug;
  VideoTabStoryList({
    @required this.categorySlug,
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
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container();
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
                  return Container();
                },
                childCount: 1,
              ),
            );
          }

          return _tabStoryList(
            storyListItemList: storyListItemList,
          );
        }

        if (state is TabStoryListLoadingMore) {
          StoryListItemList storyListItemList = state.storyListItemList;
          return _tabStoryList(
            storyListItemList: storyListItemList, 
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
    StoryListItemList storyListItemList,
    bool isLoading = false
  }) {
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
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: VideoStoryListItem(storyListItem: storyListItemList[index]),
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