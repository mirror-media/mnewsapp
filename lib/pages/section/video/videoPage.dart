import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/categories/bloc.dart';
import 'package:tv/services/categoryService.dart';
import 'package:tv/pages/section/video/videoCategoryTab.dart';

class VideoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CategoriesBloc(categoryRepos: CategoryServices(isVideo: true)),
      child: VideoCategoryTab(),
    );
  }
}
