import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/editorChoice/bloc.dart';
import 'package:tv/blocs/editorChoice/events.dart';
import 'package:tv/blocs/tabStoryList/bloc.dart';
import 'package:tv/services/editorChoiceService.dart';
import 'package:tv/services/tabStoryListService.dart';
import 'package:tv/widgets/editorChoiceCarousel.dart';
import 'package:tv/pages/section/news/popularTabStoryList.dart';
import 'package:tv/pages/section/news/tabStoryList.dart';

class TabContent extends StatefulWidget {
  final String categorySlug;
  final bool needCarousel;
  TabContent({
    @required this.categorySlug,
    this.needCarousel = false,
  });

  @override
  _TabContentState createState() => _TabContentState();
}

class _TabContentState extends State<TabContent> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if(widget.needCarousel)
          SliverToBoxAdapter(
            child: BlocProvider(
              create: (context) => EditorChoiceBloc(editorChoiceRepos: EditorChoiceServices()),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: BuildEditorChoiceCarousel(editorChoiceEvent: EditorChoiceEvents.fetchEditorChoiceList),
              ),
            ),
          ),
        BlocProvider(
          create: (context) => TabStoryListBloc(tabStoryListRepos: TabStoryListServices()),
          child: widget.categorySlug == 'popular'
          ? PopularTabStoryList()
          : BuildTabStoryList(
              categorySlug: widget.categorySlug,
              needCarousel: widget.needCarousel,
            ),
        ),
      ],
    );
  }
}