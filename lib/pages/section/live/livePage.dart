import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tv/blocs/promotionVideo/bloc.dart';
import 'package:tv/blocs/youtubePlaylist/bloc.dart';
import 'package:tv/helpers/adHelper.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/pages/section/live/promotionVideos.dart';
import 'package:tv/services/promotionVideosService.dart';
import 'package:tv/services/youtubePlaylistService.dart';
import 'package:tv/pages/section/live/liveSite.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';
import 'package:tv/widgets/story/youtubeViewer.dart';

class LivePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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

            InlineBannerAdWidget(adUnitId: adHelper!.liveAT1AdUnitId,),

            BlocProvider(
              create: (context) => YoutubePlaylistBloc(youtubePlaylistRepos: YoutubePlaylistServices()),
              child: LiveSite()
            ),

            InlineBannerAdWidget(adUnitId: adHelper!.liveAT2AdUnitId),

            BlocProvider(
              create: (context) => PromotionVideoBloc(promotionVideosRepos: PromotionVideosServices()),
              child: PromotionVideos()
            ),

            InlineBannerAdWidget(adUnitId: adHelper!.liveAT3AdUnitId),

            SizedBox(height: 24),
          ],
        ),
      ],
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