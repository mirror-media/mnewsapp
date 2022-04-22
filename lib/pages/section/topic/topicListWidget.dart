import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/blocs/topicList/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/helpers/paragraphFormat.dart';
import 'package:tv/models/topic.dart';
import 'package:tv/pages/section/topic/topicStoryListPage.dart';
import 'package:tv/pages/shared/tabContentNoResultWidget.dart';

class TopicListWidget extends StatefulWidget {
  @override
  _TopicListWidgetState createState() => _TopicListWidgetState();
}

class _TopicListWidgetState extends State<TopicListWidget> {
  List<Topic> topicList = [];
  ParagraphFormat paragraphFormat = ParagraphFormat();
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
            padding: EdgeInsets.only(top: 24, left: 24, right: 24),
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
    return SafeArea(
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 24,
          crossAxisSpacing: 19,
          childAspectRatio: 1.4,
        ),
        children: topicList.map((topic) => _buildItem(topic)).toList(),
      ),
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
          Text(
            topic.name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 17,
              color: themeColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
