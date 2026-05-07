import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tv/bindings/topic_story_binding.dart';
import 'package:tv/controller/topic_story_controller.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/topic.dart';
import 'package:tv/pages/section/topic/topic_story_list_widget.dart';

class TopicStoryListPage extends StatefulWidget {
  const TopicStoryListPage({super.key, required this.topic});

  final Topic topic;

  @override
  State<TopicStoryListPage> createState() => _TopicStoryListPageState();
}

class _TopicStoryListPageState extends State<TopicStoryListPage> {
  @override
  void initState() {
    super.initState();
    TopicStoryBinding(widget.topic.slug).dependencies();
  }

  @override
  void dispose() {
    if (Get.isRegistered<TopicStoryController>(tag: widget.topic.slug)) {
      Get.delete<TopicStoryController>(tag: widget.topic.slug);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.sendScreenView(
      screenName: 'TopicStoryListPage name=${widget.topic.name}',
    );
    return Scaffold(
      appBar: _buildBar(),
      body: TopicStoryListWidget(widget.topic.slug),
    );
  }

  PreferredSizeWidget _buildBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: Get.back,
      ),
      backgroundColor: appBarColor,
      centerTitle: true,
      title: ExtendedText(
        widget.topic.name,
        joinZeroWidthSpace: true,
        style: const TextStyle(
          fontSize: 17,
          color: Colors.white,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: 'Share',
          onPressed: () {
            final url =
                '${Environment().config.mNewsWebsiteLink}/topic/${widget.topic.slug}';
            SharePlus.instance.share(
              ShareParams(text: url),
            );
          },
        ),
      ],
    );
  }
}
