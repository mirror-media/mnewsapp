import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/search/bloc.dart';
import 'package:tv/blocs/search/events.dart';
import 'package:tv/blocs/search/states.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/helpers/routeGenerator.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/pages/search/searchNoResultWidget.dart';

class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  TextEditingController _textController = TextEditingController();
  ScrollController _listviewController = ScrollController();
  late bool _isLoading;
  late bool _isLoadingMax;

  @override
  void initState() {
    _isLoading = true;
    _isLoadingMax = false;
    _listviewController.addListener(() {
      if (!_isLoadingMax &&
          _listviewController.position.pixels ==
              _listviewController.position.maxScrollExtent &&
          !_isLoading) {
        _searchNextPageByKeyword(_textController.text);
      }
    });
    super.initState();
  }

  _searchNewsStoryByKeyword(String keyword) async {
    context.read<SearchBloc>().add(SearchNewsStoryByKeyword(keyword));
  }

  _searchNextPageByKeyword(String keyword) async {
    context.read<SearchBloc>().add(SearchNextPageByKeyword(keyword));
  }

  _clearKeyword() {
    _textController.clear();
    context.read<SearchBloc>().add(ClearKeyword());
  }

  @override
  void dispose() {
    _textController.dispose();
    _listviewController.dispose();
    super.dispose();
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
              _keywordTextField(width - 24),
            ],
          ),
        ),
        BlocBuilder<SearchBloc, SearchState>(
            builder: (BuildContext context, SearchState state) {
          if (state is SearchError) {
            final error = state.error;
            print('SearchError: ${error.message}');
            if (error is NoInternetException) {
              return Expanded(
                  child: error.renderWidget(
                      onPressed: () =>
                          _searchNewsStoryByKeyword(_textController.text)));
            }

            return Expanded(child: error.renderWidget());
          }

          if (state is SearchInitState) {
            return Container();
          }

          if (state is SearchLoaded) {
            _isLoading = false;
            List<StoryListItem> storyListItemList = state.storyListItemList;
            _isLoadingMax = storyListItemList.length == state.allStoryCount;

            return Expanded(
              child: _buildSearchList(
                  context, storyListItemList, _textController.text),
            );
          }

          if (state is SearchLoadingMore) {
            _isLoading = true;
            List<StoryListItem> storyListItemList = state.storyListItemList;

            return Expanded(
              child: _buildSearchList(
                  context, storyListItemList, _textController.text,
                  isLoadingMore: true),
            );
          }
          // state is loading, or other
          return _loadingWidget();
        }),
      ],
    );
  }

  Widget _keywordTextField(double width) {
    return Container(
      width: width,
      child: Theme(
        data: Theme.of(context).copyWith(
          primaryColor: Colors.grey,
        ),
        child: TextField(
            controller: _textController,
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
                onPressed: () => _clearKeyword(),
                icon: Icon(Icons.clear),
              ),
              hintText: "請輸入關鍵字",
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            onSubmitted: (value) {
              _searchNewsStoryByKeyword(_textController.text);
              AnalyticsHelper.logSearch(searchText: _textController.text);
            }),
      ),
    );
  }

  Widget _buildSearchList(
    BuildContext context,
    List<StoryListItem> storyListItemList,
    String keyword, {
    bool isLoadingMore = false,
  }) {
    if (storyListItemList.length == 0) {
      return SearchNoResultWidget(
        keyword: keyword,
      );
    }

    return ListView.separated(
      controller: _listviewController,
      separatorBuilder: (BuildContext context, int index) =>
          SizedBox(height: 16.0),
      itemCount: storyListItemList.length,
      itemBuilder: (context, index) {
        if (index == storyListItemList.length - 1 && isLoadingMore) {
          return Column(children: [
            _buildListItem(context, storyListItemList[index]),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Center(child: CupertinoActivityIndicator()),
            ),
          ]);
        }

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
        });
  }

  Widget _loadingWidget() => Center(
        child: CircularProgressIndicator.adaptive(),
      );
}
