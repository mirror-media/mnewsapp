import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/topicList/bloc.dart';
import 'package:tv/pages/section/topic/topicListWidget.dart';

class TopicListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TopicListBloc(),
      child: TopicListWidget(),
    );
  }
}
