import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/blocs/promotionVideo/bloc.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/pages/section/live/live_page_controller.dart';
import 'package:tv/pages/section/live/promotionVideos.dart';
import 'package:tv/services/promotionVideosService.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';
import 'package:tv/widgets/youtube_stream_widget.dart';

class LivePage extends GetView<LivePageController> {
  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.sendScreenView(screenName: 'LivePage');
    final TextScaleFactorController textScaleFactorController = Get.find();
    return ListView(
      children: [
        Column(
          children: [
            const SizedBox(height: 24.0),
            Row(
              children: [
                const SizedBox(width: 24.0),
                Obx(() {
                  return Text(
                    '鏡新聞 Live',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    textScaleFactor:
                        textScaleFactorController.textScaleFactor.value,
                  );
                }),
                const SizedBox(width: 8.0),
                const FaIcon(
                  FontAwesomeIcons.podcast,
                  size: 18,
                  color: Colors.red,
                )
              ],
            ),
            const SizedBox(height: 24),
            Obx(() {
              final mnewsLiveUrl = controller.rxnNewLiveUrl.value;
              return mnewsLiveUrl != null
                  ? YoutubeStreamWidget(youtubeUrl: mnewsLiveUrl)
                  : SizedBox.shrink();
            }),
            InlineBannerAdWidget(
              adUnitId: AdUnitIdHelper.getBannerAdUnitId('NewsAT1'),
              sizes: [
                AdSize.mediumRectangle,
                AdSize(width: 336, height: 280),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 24.0),
                Obx(() {
                  return Text(
                    '直播現場',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    textScaleFactor:
                        textScaleFactorController.textScaleFactor.value,
                  );
                }),
                const SizedBox(width: 8.0),
                const FaIcon(
                  FontAwesomeIcons.podcast,
                  size: 18,
                  color: Colors.red,
                )
              ],
            ),
            const SizedBox(height: 24),
            Obx(() {
              final liveCameList = controller.rxLiveCamList;
              return liveCameList.isNotEmpty
                  ? Column(
                      children: liveCameList
                          .map((element) => Column(
                            children: [
                              YoutubeStreamWidget(
                                    youtubeUrl: element,
                                  ),
                              const SizedBox(height: 12,)
                            ],
                          ))
                          .toList(),
                    )
                  : SizedBox.shrink();
            }),
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
