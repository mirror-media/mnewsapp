import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewerWidget extends StatefulWidget {
  final List<String> imageUrlList;
  final int openIndex;
  ImageViewerWidget(this.imageUrlList, {this.openIndex = 0});

  @override
  _ImageViewerWidgetState createState() => _ImageViewerWidgetState();
}

class _ImageViewerWidgetState extends State<ImageViewerWidget> {
  int nowIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    nowIndex = widget.openIndex;
    _controller = PageController(initialPage: widget.openIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(children: [
          PhotoViewGallery.builder(
            itemCount: widget.imageUrlList.length,
            pageController: _controller,
            onPageChanged: (index) {
              setState(() {
                nowIndex = index;
              });
            },
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.imageUrlList[index]),
                basePosition: Alignment.center,
                heroAttributes: PhotoViewHeroAttributes(
                  tag: "imageViewerWidget$index",
                  transitionOnUserGestures: true,
                ),
                minScale: PhotoViewComputedScale.contained,
              );
            },
            loadingBuilder: (context, progress) => Center(
              child: Container(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(),
              ),
            ),
            backgroundDecoration: BoxDecoration(color: Colors.black),
          ),
          Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 18),
            child: Text(
              '${nowIndex + 1}/${widget.imageUrlList.length}',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            iconSize: 40,
            icon: Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
        ]),
      ),
    );
  }
}
