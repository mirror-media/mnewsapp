import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/blocs/promotionVideo/bloc.dart';
import 'package:tv/blocs/youtubePlaylist/bloc.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/pages/section/live/promotionVideos.dart';
import 'package:tv/services/adService.dart';
import 'package:tv/services/promotionVideosService.dart';
import 'package:tv/services/youtubePlaylistService.dart';
import 'package:tv/pages/section/live/liveSite.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';
import 'package:tv/widgets/story/youtubeViewer.dart';

class LivePage extends StatefulWidget{
  @override
  _LivePageState createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  late List<BannerAd> _bannerAdList;

  @override
  void initState(){
    super.initState();
  }

  Future<void> _getAd() async {
    _bannerAdList = await AdService().createInlineBanner('live');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getAd(),
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          return ListView(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: _buildLiveTitle('鏡電視 Live'),
                  ),

                  YoutubeViewer(
                    mNewsLiveYoutubeId,
                    autoPlay: true,
                    isLive: true,
                    mute: true,
                  ),

                  InlineBannerAdWidget(bannerAd: _bannerAdList[0],),

                  BlocProvider(
                      create: (context) => YoutubePlaylistBloc(youtubePlaylistRepos: YoutubePlaylistServices()),
                      child: LiveSite()
                  ),

                  InlineBannerAdWidget(bannerAd: _bannerAdList[1],),

                  BlocProvider(
                      create: (context) => PromotionVideoBloc(promotionVideosRepos: PromotionVideosServices()),
                      child: PromotionVideos()
                  ),

                  InlineBannerAdWidget(bannerAd: _bannerAdList[2],),

                  SizedBox(height: 24),
                ],
              ),
            ],
          );
        }
        else if(snapshot.connectionState == ConnectionState.waiting){
          return CircularProgressIndicator();
        }
        else{
          return ListView(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: _buildLiveTitle('鏡電視 Live'),
                  ),

                  YoutubeViewer(
                    mNewsLiveYoutubeId,
                    autoPlay: true,
                    isLive: true,
                    mute: true,
                  ),

                  BlocProvider(
                      create: (context) => YoutubePlaylistBloc(youtubePlaylistRepos: YoutubePlaylistServices()),
                      child: LiveSite()
                  ),

                  BlocProvider(
                      create: (context) => PromotionVideoBloc(promotionVideosRepos: PromotionVideosServices()),
                      child: PromotionVideos()
                  ),

                  SizedBox(height: 24),
                ],
              ),
            ],
          );
        }
      }
    );
  }

  Widget _buildLiveTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 8.0),
        FaIcon(
          FontAwesomeIcons.podcast,
          size: 18,
          color: Colors.red,
        ),
      ],
    );
  }
}