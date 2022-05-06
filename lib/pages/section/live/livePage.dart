import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/blocs/live/liveCubit.dart';
import 'package:tv/blocs/promotionVideo/bloc.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/pages/section/live/liveCams.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';
import 'package:tv/widgets/liveWidget.dart';
import 'package:tv/pages/section/live/promotionVideos.dart';
import 'package:tv/services/promotionVideosService.dart';

class LivePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.sendScreenView(screenName: 'LivePage');
    return ListView(
      children: [
        Column(
          children: [
            BlocProvider(
                create: (context) => LiveCubit(),
                child: LiveWidget(
                  livePostId: Environment().config.mNewsLivePostId,
                )),
            InlineBannerAdWidget(
              adUnitId: AdUnitIdHelper.getBannerAdUnitId('NewsAT1'),
              sizes: [
                AdSize.mediumRectangle,
                AdSize(width: 336, height: 280),
              ],
            ),
            BlocProvider(
              create: (context) => LiveCubit(),
              child: LiveCams(),
            ),
            InlineBannerAdWidget(
              adUnitId: AdUnitIdHelper.getBannerAdUnitId('NewsAT2'),
              sizes: [
                AdSize.mediumRectangle,
                AdSize(width: 336, height: 280),
                AdSize(width: 320, height: 480),
              ],
            ),
            BlocProvider(
                create: (context) => PromotionVideoBloc(
                    promotionVideosRepos: PromotionVideosServices()),
                child: PromotionVideos()),
            InlineBannerAdWidget(
              adUnitId: AdUnitIdHelper.getBannerAdUnitId('NewsAT3'),
              sizes: [
                AdSize.mediumRectangle,
                AdSize(width: 336, height: 280),
              ],
            ),
            SizedBox(height: 24),
          ],
        ),
      ],
    );
  }
}
