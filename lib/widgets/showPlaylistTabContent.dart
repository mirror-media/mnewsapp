import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tv/helpers/dateTimeFormat.dart';
import 'package:tv/models/youtubePlaylistInfo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/youtubePlaylist/bloc.dart';
import 'package:tv/blocs/youtubePlaylist/events.dart';
import 'package:tv/blocs/youtubePlaylist/states.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:tv/models/youtubePlaylistItemList.dart';

class ShowPlaylistTabContent extends StatefulWidget {
  final YoutubePlaylistInfo youtubePlaylistInfo;
  ShowPlaylistTabContent({
    Key key,
    @required this.youtubePlaylistInfo,
  }) : super(key: key);

  @override
  _ShowPlaylistTabContentState createState() => _ShowPlaylistTabContentState();
}

class _ShowPlaylistTabContentState extends State<ShowPlaylistTabContent> {
  final fetchPlaylistMaxResult = 10;

  @override
  void initState() {
    _fetchSnippetByPlaylistId(widget.youtubePlaylistInfo.youtubePlayListId);
    super.initState();
  }

  _fetchSnippetByPlaylistId(String id) async {
    context.read<YoutubePlaylistBloc>().add(FetchSnippetByPlaylistId(id, maxResult: fetchPlaylistMaxResult));
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubePlaylistBloc, YoutubePlaylistState>(
      builder: (BuildContext context, YoutubePlaylistState state) {
        if (state is YoutubePlaylistError) {
          final error = state.error;
          print('LiveSiteError: ${error.message}');
          return Container();
        }
        if (state is YoutubePlaylistLoaded) {
          YoutubePlaylistItemList youtubePlaylistItemList = state.youtubePlaylistItemList;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLiveTitle(widget.youtubePlaylistInfo.name),
              SizedBox(height: 24),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) => SizedBox(height: 16.0),
                itemCount: youtubePlaylistItemList.length,
                itemBuilder: (context, index) {
                  return _buildListItem(
                    context,
                    youtubePlaylistItemList[index]
                  );
                }
              ),
            ],
          );
        }

        // state is Init, loading, or other 
        return Container();
      }
    );
  }

  Widget _buildLiveTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildListItem(BuildContext context, YoutubePlaylistItem youtubePlaylistItem) {
    DateTimeFormat dateTimeFormat = DateTimeFormat();
    var width = MediaQuery.of(context).size.width;
    double imageWidth = 33.3 * (width - 48) / 100;
    double imageHeight = imageWidth/16*9;

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
                SizedBox(height: 12),
                Text(
                  dateTimeFormat.changeStringToDisplayString(
                    youtubePlaylistItem.publishedAt, 
                    'yyyy-MM-ddTHH:mm:ssZ', 
                    'yyyy年MM月dd日'
                  ),
                  style: TextStyle(
                    color: Color(0xff757575),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      onTap: () {}
    );
  }
}