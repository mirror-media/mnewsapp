import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tv/blocs/editorChoice/bloc.dart';
import 'package:tv/blocs/editorChoice/events.dart';
import 'package:tv/blocs/editorChoice/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/helpers/routeGenerator.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/pages/shared/tabContentNoResultWidget.dart';

class BuildEditorChoiceStoryList extends StatefulWidget {
  final EditorChoiceEvents editorChoiceEvent;
  BuildEditorChoiceStoryList({
    required this.editorChoiceEvent,
  });

  @override
  _BuildEditorChoiceStoryListState createState() => _BuildEditorChoiceStoryListState();
}

class _BuildEditorChoiceStoryListState extends State<BuildEditorChoiceStoryList> {
  @override
  void initState() {
    _loadEditorChoiceList(widget.editorChoiceEvent);
    super.initState();
  }

  _loadEditorChoiceList(EditorChoiceEvents editorChoiceEvent) async {
    context.read<EditorChoiceBloc>().add(editorChoiceEvent);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditorChoiceBloc, EditorChoiceState>(
      builder: (BuildContext context, EditorChoiceState state) {
        if (state is EditorChoiceError) {
          final error = state.error;
          print('EditorChoiceError: ${error.message}');
          if( error is NoInternetException) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return error.renderWidget(
                    onPressed: () => _loadEditorChoiceList(widget.editorChoiceEvent),
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
        if (state is EditorChoiceLoaded) {
          StoryListItemList editorChoiceList = state.editorChoiceList;

          if(editorChoiceList.length == 0) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return TabContentNoResultWidget();
                },
                childCount: 1
              ),
            );
          }
          return _tabStoryList(storyListItemList: editorChoiceList);
        }

        // state is Init, loading, or other 
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return _loadMoreWidget();
            },
            childCount: 1
          ),
        );
      }
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

Widget _tabStoryList({
    required StoryListItemList storyListItemList,
  }) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: _buildListItem(context, storyListItemList[index]),
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
}