import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/story/bloc.dart';
import 'package:tv/pages/section/ombuds/ombudsWidget.dart';
import 'package:tv/services/storyService.dart';

class OmbudsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocProvider(
        create: (context) => StoryBloc(storyRepos: StoryServices()),
        child: OmbudsWidget()
      ),
    );
  }
}