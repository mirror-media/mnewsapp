import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tv/blocs/topicStoryList/bloc.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/topic.dart';
import 'package:tv/pages/section/topic/topicStoryListWidget.dart';

class TopicStoryListPage extends StatelessWidget {
  final Topic topic;
  TopicStoryListPage({required this.topic});
  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.sendScreenView(
        screenName: 'TopicStoryListPage name=${topic.name}');
    return Scaffold(
      appBar: _buildBar(context),
      body: BlocProvider(
        create: (context) => TopicStoryListBloc(),
        child: TopicStoryListWidget(topic.slug),
      ),
    );
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: appBarColor,
      centerTitle: true,
      title: Text(
        topic.name,
        style: TextStyle(
          fontSize: 17,
          color: Colors.white,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.share),
          tooltip: 'Share',
          onPressed: () {
            String url =
                Environment().config.mNewsWebsiteLink + '/story/' + topic.slug;
            Share.share(url);
          },
        ),
      ],
    );
  }
}
