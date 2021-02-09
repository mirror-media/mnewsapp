import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/editorChoice/bloc.dart';
import 'package:tv/services/editorChoiceService.dart';
import 'package:tv/widgets/editorChoiceCarousel.dart';

class TabContent extends StatefulWidget {
  final bool needCarousel;
  TabContent({
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
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Text('Tab content')),
                ],
              );
            },
            childCount: 1,
          ),
        ),
      ],
    );
  }
}