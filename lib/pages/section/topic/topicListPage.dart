import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/bindings/topic_binding.dart';
import 'package:tv/controller/topic_list_controller.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/pages/section/topic/topicListWidget.dart';

class TopicListPage extends StatefulWidget {
  @override
  State<TopicListPage> createState() => _TopicListPageState();
}

class _TopicListPageState extends State<TopicListPage> {
  @override
  void initState() {
    super.initState();
    TopicBinding().dependencies();
  }

  @override
  void dispose() {
    if (Get.isRegistered<TopicListController>()) {
      Get.delete<TopicListController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.sendScreenView(screenName: 'TopicListPage');
    return TopicListWidget();
  }
}
