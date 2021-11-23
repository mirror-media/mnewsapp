import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tv/blocs/topicStoryList/bloc.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/pages/section/topic/topicStoryListWidget.dart';

class TopicStoryListPage extends StatelessWidget {
  final String slug;
  final String topicName;
  TopicStoryListPage({required this.topicName, required this.slug});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: BlocProvider(
        create: (context) => TopicStoryListBloc(),
        child: TopicStoryListWidget(slug),
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
        topicName,
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
                Environment().config.mNewsWebsiteLink + 'story/' + slug;
            Share.share(url);
          },
        ),
      ],
    );
  }
}
