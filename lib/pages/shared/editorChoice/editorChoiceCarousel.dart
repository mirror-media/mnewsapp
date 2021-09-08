import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/editorChoice/bloc.dart';
import 'package:tv/blocs/editorChoice/events.dart';
import 'package:tv/blocs/editorChoice/states.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/pages/shared/editorChoice/carouselDisplayWidget.dart';

class BuildEditorChoiceCarousel extends StatefulWidget {
  final EditorChoiceEvents editorChoiceEvent;
  BuildEditorChoiceCarousel({
    required this.editorChoiceEvent,
  });

  @override
  _BuildEditorChoiceCarouselState createState() =>
      _BuildEditorChoiceCarouselState();
}

class _BuildEditorChoiceCarouselState extends State<BuildEditorChoiceCarousel> {
  @override
  void initState() {
    _loadEditorChoiceList(widget.editorChoiceEvent);
    super.initState();
  }

  _loadEditorChoiceList(EditorChoiceEvents editorChoiceEvent) async {
    context.read<EditorChoiceBloc>().add(editorChoiceEvent);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditorChoiceBloc, EditorChoiceState>(
        builder: (BuildContext context, EditorChoiceState state) {
      if (state is EditorChoiceError) {
        final error = state.error;
        print('EditorChoiceError: ${error.message}');
        return Container();
      }
      if (state is EditorChoiceLoaded) {
        StoryListItemList editorChoiceList = state.editorChoiceList;

        if (editorChoiceList.length == 0) {
          return Container();
        }
        return EditorChoiceCarousel(
          editorChoiceList: editorChoiceList,
          aspectRatio: 4 / 3,
        );
      }

      // state is Init, loading, or other
      return Container();
    });
  }
}

class EditorChoiceCarousel extends StatefulWidget {
  final StoryListItemList editorChoiceList;
  final double aspectRatio;
  EditorChoiceCarousel({
    required this.editorChoiceList,
    this.aspectRatio = 16 / 9,
  });

  @override
  _EditorChoiceCarouselState createState() => _EditorChoiceCarouselState();
}

class _EditorChoiceCarouselState extends State<EditorChoiceCarousel> {
  CarouselController _carouselController = CarouselController();
  late CarouselOptions _options;

  @override
  void initState() {
    _options = CarouselOptions(
      viewportFraction: 1.0,
      aspectRatio: widget.aspectRatio,
      autoPlay: true,
      autoPlayInterval: Duration(seconds: 8),
      enlargeCenterPage: true,
      onPageChanged: (index, reason) {},
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return widget.editorChoiceList.length == 0
        ? Container()
        : Stack(
            children: [
              CarouselSlider(
                items: _imageSliders(width, widget.editorChoiceList),
                carouselController: _carouselController,
                options: _options,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  child: SizedBox(
                    width: width * 0.1,
                    height: width / widget.aspectRatio,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onTap: () {
                    _carouselController.previousPage();
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  child: SizedBox(
                    width: width * 0.1,
                    height: width / widget.aspectRatio,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    _carouselController.nextPage();
                  },
                ),
              ),
            ],
          );
  }

  List<Widget> _imageSliders(double width, StoryListItemList editorChoiceList) {
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
