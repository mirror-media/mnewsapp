import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/categories/bloc.dart';
import 'package:tv/pages/section/show/showCategoryTab.dart';
import 'package:tv/services/showService.dart';

class ShowPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoriesBloc(categoryRepos: ShowServices()),
      child: ShowCategoryTab(),
    );
  }
}
