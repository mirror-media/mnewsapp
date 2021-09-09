import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tv/helpers/dateTimeFormat.dart';
import 'package:tv/helpers/routeGenerator.dart';
import 'package:tv/models/adUnitId.dart';
import 'package:tv/models/youtubePlaylistInfo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/youtubePlaylist/bloc.dart';
import 'package:tv/blocs/youtubePlaylist/events.dart';
import 'package:tv/blocs/youtubePlaylist/states.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:tv/models/youtubePlaylistItemList.dart';

class ShowPlaylistTabContent extends StatefulWidget {
  final YoutubePlaylistInfo youtubePlaylistInfo;
  final ScrollController listviewController;
  final AdUnitId adUnitId;
  ShowPlaylistTabContent({
    Key? key,
    required this.youtubePlaylistInfo,
    required this.listviewController,
    required this.adUnitId,
  }) : super(key: key);

  @override
  _ShowPlaylistTabContentState createState() => _ShowPlaylistTabContentState();
}

class _ShowPlaylistTabContentState extends State<ShowPlaylistTabContent> {
  final int _fetchPlaylistMaxResult = 10;
  late bool _isLoading;
  String? _nextPagetoken;

  @override
  void initState() {
    _fetchSnippetByPlaylistId(widget.youtubePlaylistInfo.youtubePlayListId);
    _initPagetokenAndIsLoading();

    widget.listviewController.addListener(() {
      if (widget.listviewController.position.pixels ==
              widget.listviewController.position.maxScrollExtent &&
          !_isLoading &&
          _nextPagetoken != '' &&
          _nextPagetoken != null) {
        _fetchSnippetByPlaylistIdAndPageToken(
            widget.youtubePlaylistInfo.youtubePlayListId, _nextPagetoken!);
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(ShowPlaylistTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchSnippetByPlaylistId(widget.youtubePlaylistInfo.youtubePlayListId);
    _initPagetokenAndIsLoading();
  }

  _fetchSnippetByPlaylistId(String id) async {
    context
        .read<YoutubePlaylistBloc>()
        .add(FetchSnippetByPlaylistId(id, maxResults: _fetchPlaylistMaxResult));
  }

  _fetchSnippetByPlaylistIdAndPageToken(String id, String pageToken) async {
    context.read<YoutubePlaylistBloc>().add(
        FetchSnippetByPlaylistIdAndPageToken(id, pageToken,
            maxResults: _fetchPlaylistMaxResult));
  }

  _initPagetokenAndIsLoading() {
    _isLoading = true;
    _nextPagetoken = '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubePlaylistBloc, YoutubePlaylistState>(
        builder: (BuildContext context, YoutubePlaylistState state) {
      if (state is YoutubePlaylistError) {
        final error = state.error;
        print('YoutubePlaylistError: ${error.message}');
        return Container();
      }
      if (state is YoutubePlaylistLoadingMore) {
        _isLoading = true;
        YoutubePlaylistItemList youtubePlaylistItemList =
            state.youtubePlaylistItemList;
        return _buildYoutubePlaylistItemList(
            widget.youtubePlaylistInfo.youtubePlayListId,
            youtubePlaylistItemList,
            isLoading: true);
      }
      if (state is YoutubePlaylistLoadingMoreFail) {
        YoutubePlaylistItemList youtubePlaylistItemList =
            state.youtubePlaylistItemList;
        _isLoading = false;
        _nextPagetoken = youtubePlaylistItemList.nextPageToken;

        return _buildYoutubePlaylistItemList(
            widget.youtubePlaylistInfo.youtubePlayListId,
            youtubePlaylistItemList,
            isLoading: true);
      }
      if (state is YoutubePlaylistLoaded) {
        YoutubePlaylistItemList youtubePlaylistItemList =
            state.youtubePlaylistItemList;
        _isLoading = false;
        _nextPagetoken = youtubePlaylistItemList.nextPageToken;

        return _buildYoutubePlaylistItemList(
          widget.youtubePlaylistInfo.youtubePlayListId,
          youtubePlaylistItemList,
        );
      }

      // state is Init, loading, or other
      return _loadMoreWidget();
    });
  }

  Widget _buildYoutubePlaylistItemList(
      String youtubePlayListId, YoutubePlaylistItemList youtubePlaylistItemList,
      {bool isLoading = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        ListView.separated(
            //controller: widget.listviewController,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            separatorBuilder: (BuildContext context, int index) =>
                SizedBox(height: 16.0),
            itemCount: youtubePlaylistItemList.length,
            itemBuilder: (context, index) {
              return _buildListItem(
                  context, youtubePlayListId, youtubePlaylistItemList[index]);
            }),
        if (isLoading) _loadMoreWidget(),
      ],
    );
  }

  Widget _buildListItem(
    BuildContext context,
    String youtubePlayListId,
    YoutubePlaylistItem youtubePlaylistItem,
  ) {
    DateTimeFormat dateTimeFormat = DateTimeFormat();
    var width = MediaQuery.of(context).size.width;
    double imageWidth = 33.3 * (width - 48) / 100;
    double imageHeight = imageWidth / 16 * 9;

    return InkWell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedNetworkImage(
            height: imageHeight,
            width: imageWidth,
            imageUrl: youtubePlaylistItem.photoUrl,
            placeholder: (context, url) => Container(
              height: imageHeight,
              width: imageWidth,
              color: Colors.grey,
            ),
            errorWidget: (context, url, error) => Container(
              height: imageHeight,
              width: imageWidth,
              color: Colors.grey,
              child: Icon(Icons.error),
            ),
            fit: BoxFit.cover,
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                    ),
                    text: youtubePlaylistItem.name,
                  ),
                ),
                if (youtubePlaylistItem.publishedAt != null) ...[
                  SizedBox(height: 12),
                  Text(
                    dateTimeFormat.changeStringToDisplayString(
                        youtubePlaylistItem.publishedAt!,
                        'yyyy-MM-ddTHH:mm:ssZ',
                        'yyyy年MM月dd日'),
                    style: TextStyle(
                      color: Color(0xff757575),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      onTap: () => RouteGenerator.navigateToShowStory(
          context, youtubePlayListId, youtubePlaylistItem, widget.adUnitId),
    );
  }

  Widget _loadMoreWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(child: CupertinoActivityIndicator()),
    );
  }
}
