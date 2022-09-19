import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/blocs/topicList/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/helpers/adUnitIdHelper.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/helpers/paragraphFormat.dart';
import 'package:tv/models/topic.dart';
import 'package:tv/pages/section/topic/topicStoryListPage.dart';
import 'package:tv/pages/shared/tabContentNoResultWidget.dart';
import 'package:tv/widgets/inlineBannerAdWidget.dart';

class TopicListWidget extends StatefulWidget {
  @override
  _TopicListWidgetState createState() => _TopicListWidgetState();
}

class _TopicListWidgetState extends State<TopicListWidget> {
  List<Topic> topicList = [];
  ParagraphFormat paragraphFormat = ParagraphFormat();
  final TextScaleFactorController textScaleFactorController = Get.find();
  @override
  void initState() {
    _fetchTopicList();
    super.initState();
  }

  _fetchTopicList() {
    context.read<TopicListBloc>().add(FetchTopicList());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopicListBloc, TopicListState>(
      builder: (BuildContext context, TopicListState state) {
        if (state.status == TopicListStatus.error) {
          final error = state.error;
          print('TopicListError: ${error.message}');
          if (error is NoInternetException) {
            return error.renderWidget(onPressed: () => _fetchTopicList());
          }

          return error.renderWidget();
        }

        if (state.status == TopicListStatus.loaded) {
          topicList = state.topicList!;
          if (topicList.isEmpty) {
            return TabContentNoResultWidget();
          }
          return Container(
            color: Colors.white,
            child: _buildTopicList(),
          );
        }

        return Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  Widget _buildTopicList() {
    List<Topic> firstSixTopics = [];
    List<Topic> sixToTwelveTopics = [];
    List<Topic> otherTopics = [];
    for (int i = 0; i < topicList.length; i++) {
      if (i < 6) {
        firstSixTopics.add(topicList[i]);
      } else if (i < 12) {
        sixToTwelveTopics.add(topicList[i]);
      } else {
        otherTopics.add(topicList[i]);
      }
    }
    return SafeArea(
      child: ListView(
        children: [
          InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('TopicHD'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
            ],
            wantKeepAlive: true,
          ),
          _buildGridView(firstSixTopics),
          InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('TopicAT1'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
              AdSize(width: 320, height: 480),
            ],
            wantKeepAlive: true,
          ),
          _buildGridView(sixToTwelveTopics),
          InlineBannerAdWidget(
            adUnitId: AdUnitIdHelper.getBannerAdUnitId('TopicAT2'),
            sizes: [
              AdSize.mediumRectangle,
              AdSize(width: 336, height: 280),
            ],
            wantKeepAlive: true,
          ),
          _buildGridView(otherTopics),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Topic> topicList) {
    return GridView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 19,
        childAspectRatio: 1.23,
      ),
      children: topicList.map((topic) => _buildItem(topic)).toList(),
    );
  }

  Widget _buildItem(Topic topic) {
    double imageWidth = (Get.width - 48 - 19) / 2;
    double imageHeight = imageWidth / 2;
    return GestureDetector(
      onTap: () => Get.to(() => TopicStoryListPage(
            topic: topic,
          )),
      child: Column(
        children: [
          if (topic.photoUrl != null)
            CachedNetworkImage(
              imageUrl: topic.photoUrl!,
              width: imageWidth,
              height: imageHeight,
              placeholder: (context, url) => Container(
                width: imageWidth,
                height: imageHeight,
                color: Colors.grey,
              ),
              errorWidget: (context, url, error) => Container(
                width: imageWidth,
                height: imageHeight,
                color: Colors.grey,
                child: Icon(Icons.error),
              ),
              fit: BoxFit.contain,
            ),
          if (topic.photoUrl == null)
            Container(
              width: imageWidth,
              height: imageHeight,
              color: Colors.grey,
            ),
          const SizedBox(
            height: 8,
          ),
          Obx(
            () => ExtendedText(
              topic.name,
              joinZeroWidthSpace: true,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: themeColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaleFactor: textScaleFactorController.textScaleFactor.value,
            ),
          ),
        ],
      ),
    );
  }
}
