import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/editorChoice/bloc.dart';
import 'package:tv/blocs/editorChoice/events.dart';
import 'package:tv/services/editorChoiceService.dart';
import 'package:tv/widgets/editorChoiceStoryList.dart';

class VideoTabContent extends StatefulWidget {
  final String categorySlug;
  final bool needCarousel;
  VideoTabContent({
    @required this.categorySlug,
    this.needCarousel = false,
  });

  @override
  _VideoTabContentState createState() => _VideoTabContentState();
}

class _VideoTabContentState extends State<VideoTabContent> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if(widget.needCarousel)
          BlocProvider(
            create: (context) => EditorChoiceBloc(editorChoiceRepos: EditorChoiceServices()),
            child: BuildEditorChoiceStoryList(editorChoiceEvent: EditorChoiceEvents.fetchVideoEditorChoiceList),
          ),
        
        if(!widget.needCarousel)
          SliverToBoxAdapter(child: Center(child: Text(widget.categorySlug))),
      ],
    );
  }
}