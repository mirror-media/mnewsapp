import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tv/blocs/newsMarquee/bloc.dart';
import 'package:tv/blocs/newsMarquee/events.dart';
import 'package:tv/blocs/newsMarquee/states.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/data/value/string_default.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/pages/shared/newsMarquee/marqueeWidget.dart';
import 'package:tv/pages/storyPage.dart';

class BuildNewsMarquee extends StatefulWidget {
  const BuildNewsMarquee({super.key});

  @override
  State<BuildNewsMarquee> createState() => _BuildNewsMarqueeState();
}

class _BuildNewsMarqueeState extends State<BuildNewsMarquee> {
  @override
  void initState() {
    super.initState();
    _loadNewsList();
  }

  void _loadNewsList() {
    context.read<NewsMarqueeBloc>().add(NewsMarqueeEvents.fetchNewsList);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsMarqueeBloc, NewsMarqueeState>(
      builder: (context, state) {
        if (state is NewsMarqueeError) {
          final error = state.error;
          print('NewsMarqueeError: ${error.message}');
          return const SizedBox();
        }

        if (state is NewsMarqueeLoaded) {
          final newsList = state.newsList;
          if (newsList.isEmpty) {
            return const SizedBox();
          }
          return NewsMarquee(newsList: newsList);
        }

        // Init or Loading state
        return const SizedBox();
      },
    );
  }
}

class NewsMarquee extends StatefulWidget {
  final List<StoryListItem> newsList;
  final Axis direction;
  final double height;
  final Duration animationDuration;
  final Duration backDuration;
  final Duration pauseDuration;

  const NewsMarquee({
    super.key,
    required this.newsList,
    this.direction = Axis.horizontal,
    this.height = 48.0,
    this.animationDuration = const Duration(milliseconds: 3000),
    this.backDuration = const Duration(milliseconds: 800),
    this.pauseDuration = const Duration(milliseconds: 800),
  });

  @override
  State<NewsMarquee> createState() => _NewsMarqueeState();
}

class _NewsMarqueeState extends State<NewsMarquee> {
  late final carousel.CarouselSliderController _carouselController;
  late carousel.CarouselOptions _options;
  final TextScaleFactorController textScaleFactorController = Get.find();

  @override
  void initState() {
    super.initState();
    _carouselController = carousel.CarouselSliderController();
    _options = carousel.CarouselOptions(
      scrollPhysics: const NeverScrollableScrollPhysics(),
      height: widget.height,
      viewportFraction: 1,
      scrollDirection: Axis.vertical,
      initialPage: 0,
      autoPlay: true,
      autoPlayInterval: const Duration(milliseconds: 6000),
      enableInfiniteScroll: false,
      enlargeCenterPage: false,
      onPageChanged: (index, reason) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Container(
          color: newsMarqueeLeadingColor,
          padding: const EdgeInsets.all(12.0),
          child: Obx(() => Text(
            '最新',
            style: TextStyle(fontSize: 17, color: newsMarqueeContentColor),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          )),
        ),
        Expanded(
          child: carousel.CarouselSlider(
            items: _buildList(width, widget.newsList),
            carouselController: _carouselController,
            options: _options,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildList(double width, List<StoryListItem> newsList) {
    return List.generate(newsList.length, (i) {
      final story = newsList[i];
      return InkWell(
        onTap: () {
          AnalyticsHelper.logClick(
            slug: story.slug ?? StringDefault.nullString,
            title: story.name ?? StringDefault.nullString,
            location: 'HomePage_快訊跑馬燈',
          );
          if (story.slug == null) return;
          Get.to(() => StoryPage(slug: story.slug!));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            width: width,
            child: MarqueeWidget(
              animationDuration: const Duration(milliseconds: 4000),
              child: Obx(() => AutoSizeText(
                story.name ?? StringDefault.nullString,
                style: TextStyle(fontSize: 17, color: newsMarqueeContentColor),
                textScaleFactor: textScaleFactorController.textScaleFactor.value,
              )),
            ),
          ),
        ),
      );
    });
  }
}
