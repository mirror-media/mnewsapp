import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/bindings/news_marquee_binding.dart';
import 'package:tv/controller/news_marquee_controller.dart';
import 'package:tv/controller/text_scale_factor_controller.dart';
import 'package:tv/data/value/string_default.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/widgets/news_marquee/marquee_widget.dart';
import 'package:tv/pages/story_page.dart';
import 'package:tv/services/newsMarqueeService.dart';

class BuildNewsMarquee extends StatefulWidget {
  const BuildNewsMarquee({
    super.key,
    this.tag = 'default_news_marquee',
  });

  final String tag;

  @override
  State<BuildNewsMarquee> createState() => _BuildNewsMarqueeState();
}

class _BuildNewsMarqueeState extends State<BuildNewsMarquee> {
  late final NewsMarqueeController controller;

  @override
  void initState() {
    super.initState();
    NewsMarqueeBinding(widget.tag).dependencies();
    controller = Get.find<NewsMarqueeController>(tag: widget.tag);
  }

  @override
  void dispose() {
    if (Get.isRegistered<NewsMarqueeController>(tag: widget.tag)) {
      Get.delete<NewsMarqueeController>(tag: widget.tag);
    }
    if (Get.isRegistered<NewsMarqueeServices>(tag: widget.tag)) {
      Get.delete<NewsMarqueeServices>(tag: widget.tag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.error.value != null) {
        return const SizedBox();
      }

      final newsList = controller.newsList.toList();
      if (newsList.isEmpty) {
        return const SizedBox();
      }

      return NewsMarquee(newsList: newsList);
    });
  }
}

class NewsMarquee extends StatefulWidget {
  const NewsMarquee({
    super.key,
    required this.newsList,
    this.direction = Axis.horizontal,
    this.height = 48.0,
    this.animationDuration = const Duration(milliseconds: 3000),
    this.backDuration = const Duration(milliseconds: 800),
    this.pauseDuration = const Duration(milliseconds: 800),
  });

  final List<StoryListItem> newsList;
  final Axis direction;
  final double height;
  final Duration animationDuration;
  final Duration backDuration;
  final Duration pauseDuration;

  @override
  State<NewsMarquee> createState() => _NewsMarqueeState();
}

class _NewsMarqueeState extends State<NewsMarquee> {
  late final carousel.CarouselSliderController carouselController;
  late carousel.CarouselOptions options;
  final TextScaleFactorController textScaleFactorController = Get.find();

  @override
  void initState() {
    super.initState();
    carouselController = carousel.CarouselSliderController();
    options = carousel.CarouselOptions(
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
          child: Obx(
            () => Text(
              '最新',
              style: const TextStyle(
                fontSize: 17,
                color: newsMarqueeContentColor,
              ),
              textScaleFactor: textScaleFactorController.textScaleFactor.value,
            ),
          ),
        ),
        Expanded(
          child: carousel.CarouselSlider(
            items: buildList(width, widget.newsList),
            carouselController: carouselController,
            options: options,
          ),
        ),
      ],
    );
  }

  List<Widget> buildList(double width, List<StoryListItem> newsList) {
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
              child: Obx(
                () => AutoSizeText(
                  story.name ?? StringDefault.nullString,
                  style: const TextStyle(
                    fontSize: 17,
                    color: newsMarqueeContentColor,
                  ),
                  textScaleFactor:
                      textScaleFactorController.textScaleFactor.value,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
