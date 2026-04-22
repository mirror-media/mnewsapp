import 'package:flutter/material.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/pages/shared/editorChoice/carouselDisplayWidget.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;

class EditorChoiceCarousel extends StatefulWidget {
  final List<StoryListItem> editorChoiceList;
  final double aspectRatio;

  const EditorChoiceCarousel({
    super.key,
    required this.editorChoiceList,
    this.aspectRatio = 16 / 9,
  });

  @override
  _EditorChoiceCarouselState createState() => _EditorChoiceCarouselState();
}

class _EditorChoiceCarouselState extends State<EditorChoiceCarousel> {
  final carousel.CarouselSliderController _carouselController = carousel.CarouselSliderController();
  late carousel.CarouselOptions _options;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double height = width / widget.aspectRatio;

    if (height > 700) {
      height = 700;
    } else if (height > 500) {
      height = (height ~/ 100) * 100;
    }

    _options = carousel.CarouselOptions(
      viewportFraction: 1.0,
      aspectRatio: widget.aspectRatio,
      autoPlay: true,
      autoPlayInterval: const Duration(seconds: 8),
      enlargeCenterPage: true,
      onPageChanged: (index, reason) {},
      height: height + 20,
    );

    return widget.editorChoiceList.isEmpty
        ? const SizedBox()
        : Stack(
      children: [
        carousel.CarouselSlider(
          items: _imageSliders(width, widget.editorChoiceList),
          carouselController: _carouselController,
          options: _options,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () {
              _carouselController.previousPage();
            },
            child: SizedBox(
              width: width * 0.1,
              height: height,
              child: const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () {
              _carouselController.nextPage();
            },
            child: SizedBox(
              width: width * 0.1,
              height: height,
              child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _imageSliders(double width, List<StoryListItem> editorChoiceList) {
    return editorChoiceList
        .map(
          (item) => CarouselDisplayWidget(
        storyListItem: item,
        width: width,
      ),
    )
        .toList();
  }
}
