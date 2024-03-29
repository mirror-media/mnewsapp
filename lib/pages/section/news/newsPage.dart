import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/categories/bloc.dart';
import 'package:tv/blocs/election/election_cubit.dart';
import 'package:tv/blocs/live/liveCubit.dart';
import 'package:tv/services/categoryService.dart';
import 'package:tv/pages/section/news/newsCategoryTab.dart';
import 'package:tv/services/electionService.dart';

class NewsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CategoriesBloc(
            categoryRepos: CategoryServices(),
          ),
        ),
        BlocProvider(create: (context) => LiveCubit()),
        BlocProvider(
          create: (context) => ElectionCubit(
            repos: ElectionService(),
          ),
        ),
      ],
      child: NewsCategoryTab(),
    );
  }
}
