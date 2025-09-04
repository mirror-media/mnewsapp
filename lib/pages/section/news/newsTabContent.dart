import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/editorChoice/bloc.dart';
import 'package:tv/blocs/tabStoryList/bloc.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/pages/section/news/election/electionWidget.dart';
import 'package:tv/pages/section/news/newsPopularTabStoryList.dart';
import 'package:tv/pages/section/news/newsTabStoryList.dart';
import 'package:tv/pages/shared/editorChoice/editorChoiceCarousel.dart' as cs;
import 'package:tv/services/editorChoiceService.dart';
import 'package:tv/services/tabStoryListService.dart';

class NewsTabContent extends StatelessWidget {
  final String categorySlug;
  final bool needCarousel;
  final bool showElectionBlock;

  NewsTabContent({
    required this.categorySlug,
    this.needCarousel = false,
    this.showElectionBlock = false,
  });

  @override
  Widget build(BuildContext context) {
    TabStoryListBloc tabStoryListBloc =
        TabStoryListBloc(tabStoryListRepos: TabStoryListServices());
    if (categorySlug == 'latest') {
      AnalyticsHelper.sendScreenView(screenName: 'HomePage');
    } else {
      AnalyticsHelper.sendScreenView(
          screenName: 'NewsPage categorySlug=$categorySlug');
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          if (showElectionBlock) ElectionWidget(),
          if (needCarousel)
            BlocProvider(
              create: (context) => EditorChoiceBloc(
                editorChoiceRepos: EditorChoiceServices(),
                tabStoryListBloc: tabStoryListBloc,
              ),
              child: cs.BuildEditorChoiceCarousel(),
            ),
          BlocProvider(
            create: (context) => tabStoryListBloc,
            child: categorySlug == 'popular'
                ? NewsPopularTabStoryList()
                : NewsTabStoryList(
                    categorySlug: categorySlug,
                    needCarousel: needCarousel,
                  ),
          ),
        ],
      ),
    );
  }
}
