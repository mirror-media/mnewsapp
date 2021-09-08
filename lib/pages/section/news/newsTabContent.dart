import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/editorChoice/bloc.dart';
import 'package:tv/blocs/editorChoice/events.dart';
import 'package:tv/blocs/tabStoryList/bloc.dart';
import 'package:tv/services/editorChoiceService.dart';
import 'package:tv/services/tabStoryListService.dart';
import 'package:tv/pages/shared/editorChoice/editorChoiceCarousel.dart';
import 'package:tv/pages/section/news/newsPopularTabStoryList.dart';
import 'package:tv/pages/section/news/newsTabStoryList.dart';

class NewsTabContent extends StatefulWidget {
  final String categorySlug;
  final bool needCarousel;
  NewsTabContent({
    required this.categorySlug,
    this.needCarousel = false,
  });

  @override
  _NewsTabContentState createState() => _NewsTabContentState();
}

class _NewsTabContentState extends State<NewsTabContent> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (widget.needCarousel)
          SliverToBoxAdapter(
            child: BlocProvider(
              create: (context) =>
                  EditorChoiceBloc(editorChoiceRepos: EditorChoiceServices()),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: BuildEditorChoiceCarousel(
                    editorChoiceEvent:
                        EditorChoiceEvents.fetchEditorChoiceList),
              ),
            ),
          ),
        BlocProvider(
          create: (context) =>
              TabStoryListBloc(tabStoryListRepos: TabStoryListServices()),
          child: widget.categorySlug == 'popular'
              ? NewsPopularTabStoryList()
              : NewsTabStoryList(
                  categorySlug: widget.categorySlug,
                  needCarousel: widget.needCarousel,
                ),
        ),
      ],
    );
  }
}
