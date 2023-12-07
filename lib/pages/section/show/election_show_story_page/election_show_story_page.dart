import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:tv/pages/section/show/election_show_story_page/election_show_story_controller.dart';
import 'package:tv/pages/section/show/election_show_story_page/widget/playlist_item.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';
import 'package:tv/widgets/youtube/youtubeWidget.dart';
/// 目前只有針對大選的部分重構成新架構
/// 後續有修改到的Tab也可以直接修改進此架構中
class ElectionShowStoryPage extends GetView<ElectionShowStoryController> {
  const ElectionShowStoryPage(
      {required this.youtubePlaylistItem, required this.tag});

  final YoutubePlaylistItem youtubePlaylistItem;
  final String tag;

  @override
  Widget build(BuildContext context) {
    controller.setYoutubeInfo(tag, youtubePlaylistItem);
    controller.interstitialAdController.ramdomShowInterstitialAd();
    return Scaffold(
      appBar: _buildBar(context),
      body: SingleChildScrollView(
        controller: controller.scrollController,
        child: Column(
          children: [
            YoutubeWidget(youtubeId: youtubePlaylistItem.youtubeVideoId),
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
            const SizedBox(height: 24),
            Obx(() {
              final renderList = controller.rxRenderYoutubeList;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return PlaylistItem(
                        playlistItem: renderList[index],
                        tag: tag,
                      );
                    },
                    separatorBuilder: (context, index) {
                      if (index == 5) {
                        return Align(
                          alignment: Alignment.center,
                          child: InlineBannerAdWidget(
                            adUnitId:
                                AdUnitIdHelper.getBannerAdUnitId('ShowAT2'),
                            sizes: [
                              AdSize.mediumRectangle,
                              AdSize(width: 336, height: 280),
                              AdSize(width: 320, height: 480),
                            ],
                            addHorizontalMargin: false,
                          ),
                        );
                      } else if (index == 10) {
                        return Align(
                          alignment: Alignment.center,
                          child: InlineBannerAdWidget(
                            adUnitId:
                                AdUnitIdHelper.getBannerAdUnitId('ShowAT3'),
                            sizes: [
                              AdSize.mediumRectangle,
                              AdSize(width: 336, height: 280),
                            ],
                            addHorizontalMargin: false,
                          ),
                        );
                      }
                      return const SizedBox(height: 16);
                    },
                    itemCount: renderList.length),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndPublishedDate() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        youtubePlaylistItem.name,
        style: TextStyle(
          color: Colors.black,
          fontSize: 22.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      if (youtubePlaylistItem.publishedAt != null) ...[
        SizedBox(height: 12),
        Text(
          youtubePlaylistItem.publishedAt ?? '',
          style: TextStyle(
            color: Color(0xff757575),
            fontSize: 15.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ]
    ]);
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
            String url = youtubeLink + 'watch?v=' + youtubePlaylistItem.youtubeVideoId;
            Share.share(url);
          },
        ),
      ],
    );
  }
}
