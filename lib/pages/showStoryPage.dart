import 'package:flutter/material.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/dateTimeFormat.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:tv/widgets/story/youtubeViewer.dart';

class ShowStoryPage extends StatefulWidget {
  final YoutubePlaylistItem youtubePlaylistItem;
  ShowStoryPage({
    @required this.youtubePlaylistItem,
  });

  @override
  _ShowStoryPageState createState() => _ShowStoryPageState();
}

class _ShowStoryPageState extends State<ShowStoryPage> {
  DateTimeFormat _dateTimeFormat = DateTimeFormat();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: ListView(
        children: [
          YoutubeViewer(
            widget.youtubePlaylistItem.youtubeVideoId
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0),
            child: _buildTitleAndPublishedDate(),
          ),
          SizedBox(height: 48),
        ],
      ),
    );
  }
  
  Widget _buildBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: appBarColor,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.share),
          tooltip: 'Share',
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildTitleAndPublishedDate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.youtubePlaylistItem.name,
          style: TextStyle(
            color: Colors.black,
            fontSize: 22.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12),
        Text(
          _dateTimeFormat.changeStringToDisplayString(
            widget.youtubePlaylistItem.publishedAt, 
            'yyyy-MM-ddTHH:mm:ssZ', 
            'yyyy年MM月dd日'
          ),
          style: TextStyle(
            color: Color(0xff757575),
            fontSize: 15.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ]
    );
  }
}