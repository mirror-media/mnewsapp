import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tv/blocs/editorChoice/bloc.dart';
import 'package:tv/blocs/editorChoice/states.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/pages/section/news/news_page_controller.dart';
import 'package:tv/pages/shared/editorChoice/carouselDisplayWidget.dart';
import 'package:tv/widgets/liveWidget.dart';
import 'package:tv/widgets/youtube_stream_widget.dart';

class BuildEditorChoiceCarousel extends StatefulWidget {
  @override
  _BuildEditorChoiceCarouselState createState() =>
      _BuildEditorChoiceCarouselState();
}

class _BuildEditorChoiceCarouselState extends State<BuildEditorChoiceCarousel> {
  final NewsPageController controller = Get.find();

  @override
  void initState() {
    super.initState();
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
      if (state is EditorChoiceLoadedAfterTabstory) {
        List<StoryListItem> editorChoiceList = state.editorChoiceList;
        List<StoryListItem> storyListItemList = state.storyListItemList;

        if (editorChoiceList.length == 0) {
          if (storyListItemList.length != 0) {
            return Column(
              children: [
                LiveWidget(
                  needBuildLiveTitle: false,
                  livePostId: Environment().config.mNewsLivePostId,
                ),
                SizedBox(
                  height: 12,
                ),
              ],
            );
          }
          return Container();
        }
        return Column(
          children: [
            Obx(() {
              final mnewLiveUrl = controller.rxnNewLiveUrl.value;
              return mnewLiveUrl != null
                  ? Column(
                      children: [
                        YoutubeStreamWidget(youtubeUrl: mnewLiveUrl),
                        const SizedBox(
                          height: 12,
                        ),
                      ],
                    )
                  : SizedBox.shrink();
            }),
            Obx(() {
              final liveCameList = controller.rxLiveCamList;
              return liveCameList.isNotEmpty
                  ? Column(
                      children: [
                        YoutubeStreamWidget(youtubeUrl: liveCameList[0]),
                        const SizedBox(
                          height: 12,
                        ),
                      ],
                    )
                  : SizedBox.shrink();
            }),
            SizedBox(
              height: 12,
            ),
            EditorChoiceCarousel(
              editorChoiceList: editorChoiceList,
              aspectRatio: 4 / 3.2,
            ),
          ],
        );
      }

      // state is Init, loading, or other
      return Container();
    });
  }
}

class EditorChoiceCarousel extends StatefulWidget {
  final List<StoryListItem> editorChoiceList;
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
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = width / widget.aspectRatio;
    if (height > 700) {
      height = 700;
    } else if (height > 500) {
      height = (height ~/ 100) * 100;
    }
    _options = CarouselOptions(
      viewportFraction: 1.0,
      aspectRatio: widget.aspectRatio,
      autoPlay: true,
      autoPlayInterval: Duration(seconds: 8),
      enlargeCenterPage: true,
      onPageChanged: (index, reason) {},
      height: height + 20,
    );
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
                    height: height,
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
                    height: height,
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

  List<Widget> _imageSliders(
      double width, List<StoryListItem> editorChoiceList) {
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
