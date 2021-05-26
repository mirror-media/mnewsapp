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

class PopularTabStoryList extends StatefulWidget {
  @override
  _PopularTabStoryListState createState() => _PopularTabStoryListState();
}

class _PopularTabStoryListState extends State<PopularTabStoryList> {
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
          print('PopularTabStoryListError: ${error.message}');
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
  }) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildTheFirstItem(context, storyListItemList[index]),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildListItem(context, storyListItemList[index]),
          );
        },
        childCount: storyListItemList.length
      ),
    );
  }

  Widget _buildTheFirstItem(BuildContext context, StoryListItem storyListItem) {
    var width = MediaQuery.of(context).size.width;

    return InkWell(
      child: Column(
        children: [
          CachedNetworkImage(
            height: width / 16 * 9,
            width: width,
            imageUrl: storyListItem.photoUrl,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              text: TextSpan(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  height: 1.5,
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

  Widget _buildListItem(BuildContext context, StoryListItem storyListItem) {
    var width = MediaQuery.of(context).size.width;
    double imageSize = 33.3 * (width - 32) / 100;

    return InkWell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              height: imageSize,
              width: imageSize,
              imageUrl: storyListItem.photoUrl,
              placeholder: (context, url) => Container(
                height: imageSize,
                width: imageSize,
                color: Colors.grey,
              ),
              errorWidget: (context, url, error) => Container(
                height: imageSize,
                width: imageSize,
                color: Colors.grey,
                child: Icon(Icons.error),
              ),
              fit: BoxFit.cover,
            ),
            SizedBox(
              width: 16,
            ),
            Expanded(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                    height: 1.5,
                  ),
                  text: storyListItem.name,
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        RouteGenerator.navigateToStory(context, storyListItem.slug);
      }
    );
  }
}