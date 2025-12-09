import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:real_time_invoice_widget/real_time_invoice/real_time_invoice_widget.dart';
import 'package:tv/core/enum/page_status.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/pages/section/news/latestTabContent/widgets/list_story_item.dart';
import 'package:tv/pages/section/news/news_page_controller.dart';
import 'package:tv/pages/shared/editorChoice/editorChoiceCarousel.dart' as cs;
import 'package:tv/widgets/inlineBannerAdWidget.dart';
import 'package:tv/widgets/youtube_stream_widget.dart';
import 'package:tv/widgets/top_iframe_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class LatestTabContent extends GetView<NewsPageController> {
  const LatestTabContent();

  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.sendScreenView(screenName: 'HomePage');
    return SingleChildScrollView(
      controller: controller.scrollController,
      child: Column(
        children: [
          Obx(() {
            final isElectionShow = controller.rxIsElectionShow.value;
            return isElectionShow
                ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 27),
                  child: RealTimeInvoiceWidget(
                    isPackage: true,
                    getMoreButtonClick: () async {
                      if (!await launchUrl(Uri.parse(
                          Environment().config.electionGetMoreWebpage))) {
                        throw Exception('Could not launch');
                      }
                    },
                    width: Get.width - 54,
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
              ],
            )
                : const SizedBox.shrink();
          }),
          // Top Iframe Widget
          const TopIframeWidget(),
          Obx(() {
            final mnewLiveUrl = controller.rxnNewLiveUrl.value;
            return mnewLiveUrl != null
                ? Column(
              children: [
                YoutubeStreamWidget(youtubeUrl: mnewLiveUrl),
                const SizedBox(
                  height: 12,
                ),
              ],
            )
                : SizedBox.shrink();
          }),
          Obx(() {
            final liveCameList = controller.rxLiveCamList;
            return liveCameList.isNotEmpty
                ? Column(
              children: [
                YoutubeStreamWidget(youtubeUrl: liveCameList[0]),
                const SizedBox(
                  height: 12,
                ),
              ],
            )
                : SizedBox.shrink();
          }),
          GestureDetector(
            onTap: () async {
              final url = Uri.parse("https://mnews.oen.tw/");
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                throw Exception("Could not launch");
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Image.asset(
                mnewsAdEntry,
                fit: BoxFit.fitWidth,
                width: double.infinity,
              ),
            ),
          ),
          Obx(() {
            final editorChoiceList = controller.rxEditorChoiceList;
            return editorChoiceList.isNotEmpty
                ? cs.EditorChoiceCarousel(
              editorChoiceList: editorChoiceList,
              aspectRatio: 4 / 3.2,
            )
                : const SizedBox.shrink();
          }),
          Obx(() {
            final String? url = controller.rxBannerData['url'];
            final String? imageUrl = controller.rxBannerData['imageUrl'];
            final isBannerShow = controller.rxIsBannerShow.value;
            return (isBannerShow &&
                url?.isNotEmpty == true &&
                imageUrl?.isNotEmpty == true)
                ? GestureDetector(
              onTap: () async {
                if (!await launchUrl(Uri.parse(url!),
                    mode: LaunchMode.externalApplication)) {
                  throw Exception('Could not launch $url');
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.zero,
                child: Image.network(
                  imageUrl!,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
            )
                : const SizedBox.shrink();
          }),
          InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('NewsAT1'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
            ],
          ),
          Obx(() {
            final articleList = controller.rxRenderStoryList;
            return ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ListStoryItem(item: articleList[index]),
                  );
                },
                separatorBuilder: (context, index) {
                  if (index == 6) {
                    return InlineBannerAdWidget(
                      adUnitId: AdUnitIdHelper.getBannerAdUnitId('NewsAT2'),
                      sizes: [
                        AdSize.mediumRectangle,
                        AdSize(width: 336, height: 280),
                        AdSize(width: 320, height: 480),
                      ],
                    );
                  } else if (index == 10) {
                    return InlineBannerAdWidget(
                      adUnitId: AdUnitIdHelper.getBannerAdUnitId('NewsAT3'),
                      sizes: [
                        AdSize.mediumRectangle,
                        AdSize(width: 336, height: 280),
                        AdSize(width: 320, height: 480),
                      ],
                    );
                  }
                  return SizedBox(
                    height: 16,
                  );
                },
                itemCount: articleList.length);
          }),
          Obx(() {
            final pageStatus = controller.rxPageStatus.value;
            return pageStatus == PageStatus.loading
                ? Center(child: CircularProgressIndicator())
                : SizedBox.shrink();
          }),
          SizedBox(height: 30)
        ],
      ),
    );
  }
}
