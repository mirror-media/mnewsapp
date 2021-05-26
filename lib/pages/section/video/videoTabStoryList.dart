import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/tabStoryList/bloc.dart';
import 'package:tv/blocs/tabStoryList/events.dart';
import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/helpers/routeGenerator.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/models/storyListItemList.dart';

class BuildVideoTabStoryList extends StatefulWidget {
  final String categorySlug;
  BuildVideoTabStoryList({
    @required this.categorySlug,
  });

  @override
  _BuildVideoTabStoryListState createState() => _BuildVideoTabStoryListState();
}

class _BuildVideoTabStoryListState extends State<BuildVideoTabStoryList> {
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
                child: _buildListItem(context, storyListItemList[index]),
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

  Widget _buildListItem(BuildContext context, StoryListItem storyListItem) {

    return InkWell(
      child: Column(
        children: [
          _displayStoryImage(storyListItem.photoUrl),
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 0.0),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              text: TextSpan(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22.0,
                  height: 1.5,
                  fontWeight: FontWeight.w500
                ),
                text: storyListItem.name,
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        RouteGenerator.navigateToStory(context, storyListItem.slug);
      }
    );
  }

  Widget _displayStoryImage(String photoUrl) {
    var width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: width / 16 * 9,
      width: width,
      child: Stack(
        children: [
          CachedNetworkImage(
            height: width / 16 * 9,
            width: width,
            imageUrl: photoUrl,
            placeholder: (context, url) => Container(
              height: width / 16 * 9,
              width: width,
              color: Colors.grey,
            ),
            errorWidget: (context, url, error) => Container(
              height: width / 16 * 9,
              width: width,
              color: Colors.grey,
              child: Icon(Icons.error),
            ),
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 40.0 + 8.0,
                color: Colors.black45,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_arrow,
                        size: 12,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '影音',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ),
          ),
        ],
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