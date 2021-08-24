import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/story/bloc.dart';
import 'package:tv/blocs/video/video_cubit.dart';
import 'package:tv/pages/section/ombuds/ombudsWidget.dart';
import 'package:tv/services/storyService.dart';

class OmbudsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => StoryBloc(storyRepos: StoryServices()),
          ),
          BlocProvider(
            create: (context) => VideoCubit(),
          ),
        ],
        child: OmbudsWidget(),
      ),
    );
  }
}