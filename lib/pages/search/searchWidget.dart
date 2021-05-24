import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/search/bloc.dart';
import 'package:tv/blocs/search/events.dart';
import 'package:tv/blocs/search/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/helpers/routeGenerator.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/models/storyListItemList.dart';

class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  _searchNewsStoryByKeyword(String keyword) async {
    context.read<SearchBloc>().add(SearchNewsStoryByKeyword(keyword));
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 24 is padding 12*2, 12 is gap, 52 is IconButton size
              _keywordTextField(width - 24 - 12 - 52),
              _searchButton(),
            ],
          ),
        ),
        BlocBuilder<SearchBloc, SearchState>(
          builder: (BuildContext context, SearchState state) {
            if (state is SearchError) {
              final error = state.error;
              print('SearchError: ${error.message}');
              if( error is NoInternetException) {
                return Expanded(child: error.renderWidget(onPressed: () => _searchNewsStoryByKeyword(_controller.text)));
              } 
              
              return Expanded(child: error.renderWidget());
            }

            if(state is SearchInitState) {
              return Container();
            }

            if (state is SearchLoaded) {
              StoryListItemList storyListItemList = state.storyListItemList;
              
              return Expanded(child: _buildSearchList(context, storyListItemList));
            }

            // state is loading, or other 
            return _loadingWidget();
          }
        ),
      ],
    );
  }

  Widget _keywordTextField(double width) {
    return Container(
      width: width,
      child: Theme(
        data: Theme.of(context).copyWith(primaryColor: Colors.grey,),
        child: TextField(
          controller: _controller,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(3.0),
              ),
              borderSide: BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
            suffixIcon: IconButton(
              onPressed: () => _controller.clear(),
              icon: Icon(Icons.clear),
            ),
            hintText: "請輸入關鍵字",
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          onSubmitted: (value) {
            _searchNewsStoryByKeyword(_controller.text);
          }
        ),
      ),
    );
  }

  Widget _searchButton() {
    return IconButton(
      iconSize: 36,
      icon: Icon(
        Icons.search,
        color: Colors.grey,
      ),
      onPressed: () {
        _searchNewsStoryByKeyword(_controller.text);
      },
    );
  }

  Widget _buildSearchList(BuildContext context, StoryListItemList storyListItemList) {
    if(storyListItemList.length == 0) {
      return Center(child: Text('no result'));
    }

    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) => SizedBox(height: 16.0),
      itemCount: storyListItemList.length,
      itemBuilder: (context, index) {
        return _buildListItem(context, storyListItemList[index]);
      },
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

  Widget _loadingWidget() =>
      Center(
        child: CircularProgressIndicator(),
      );
}