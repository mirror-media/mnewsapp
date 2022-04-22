import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/youtubePlaylist/bloc.dart';
import 'package:tv/controller/interstitialAdController.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/dateTimeFormat.dart';
import 'package:tv/models/youtubePlaylistInfo.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:tv/pages/section/show/showPlaylistTabContent.dart';
import 'package:tv/services/youtubePlaylistService.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';
import 'package:tv/widgets/story/youtubePlayer.dart';

class ShowStoryPage extends StatefulWidget {
  final String youtubePlayListId;
  final YoutubePlaylistItem youtubePlaylistItem;
  ShowStoryPage({
    required this.youtubePlayListId,
    required this.youtubePlaylistItem,
  });

  @override
  _ShowStoryPageState createState() => _ShowStoryPageState();
}

class _ShowStoryPageState extends State<ShowStoryPage> {
  ScrollController _listviewController = ScrollController();
  DateTimeFormat _dateTimeFormat = DateTimeFormat();
  final interstitialAdController = Get.find<InterstitialAdController>();

  @override
  void dispose() {
    _listviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.sendScreenView(
        screenName: 'ShowStoryPage title=${widget.youtubePlaylistItem.name}');
    interstitialAdController.ramdomShowInterstitialAd();
    return Scaffold(
      appBar: _buildBar(context),
      body: ListView(
        controller: _listviewController,
        children: [
          YoutubePlayer(widget.youtubePlaylistItem.youtubeVideoId),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0),
            child: _buildTitleAndPublishedDate(),
          ),
          InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('ShowAT1'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0),
            child: Text(
              '更多節目內容',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0),
            child: _buildMoreShowContent(
                title: '更多節目內容', youtubePlayListId: widget.youtubePlayListId),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
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
          onPressed: () {
            String url = youtubeLink + 'watch?v=' + widget.youtubePlayListId;
            Share.share(url);
          },
        ),
      ],
    );
  }

  Widget _buildTitleAndPublishedDate() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        widget.youtubePlaylistItem.name,
        style: TextStyle(
          color: Colors.black,
          fontSize: 22.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      if (widget.youtubePlaylistItem.publishedAt != null) ...[
        SizedBox(height: 12),
        Text(
          _dateTimeFormat.changeStringToDisplayString(
              widget.youtubePlaylistItem.publishedAt!,
              'yyyy-MM-ddTHH:mm:ssZ',
              'yyyy年MM月dd日'),
          style: TextStyle(
            color: Color(0xff757575),
            fontSize: 15.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ]
    ]);
  }

  Widget _buildMoreShowContent(
      {required String title, required String youtubePlayListId}) {
    return BlocProvider(
      create: (context) =>
          YoutubePlaylistBloc(youtubePlaylistRepos: YoutubePlaylistServices()),
      child: ShowPlaylistTabContent(
        youtubePlaylistInfo: YoutubePlaylistInfo(
          name: title,
          youtubePlayListId: youtubePlayListId,
        ),
        listviewController: _listviewController,
        isMoreShow: true,
      ),
    );
  }
}
