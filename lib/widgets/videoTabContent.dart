import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        SliverToBoxAdapter(child: Center(child: Text(widget.categorySlug))),
      ],
    );
  }
}