import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tv/controller/news_election_controller.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/pages/section/news/election/municipality_item.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;

class ElectionWidget extends GetView<NewsElectionController> {
  ElectionWidget({super.key});

  final carousel.CarouselSliderController carouselController =
      carousel.CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
        if (controller.isHidden.value) return const SizedBox();

        final municipalityList = controller.municipalityList;
        final lastUpdateTime = controller.lastUpdateTime.value;
        final currentIndex = controller.currentIndex.value;

        if (municipalityList.isEmpty) return const SizedBox();

        final items = municipalityList.map((item) => MunicipalityItem(item)).toList();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: const Color.fromRGBO(0, 77, 188, 1),
              padding: const EdgeInsets.only(top: 15, bottom: 12),
              alignment: Alignment.center,
              child: const Text(
                '六都市長開票進度',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromRGBO(244, 245, 246, 1),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Flexible(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(53, 15, 54, 11),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            AnalyticsHelper.logElectionEvent(eventName: 'country_button');
                            carouselController.previousPage();
                          },
                          child: const Icon(
                            CupertinoIcons.arrowtriangle_left_fill,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          municipalityList[currentIndex].name,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            AnalyticsHelper.logElectionEvent(eventName: 'country_button');
                            carouselController.nextPage();
                          },
                          child: const Icon(
                            CupertinoIcons.arrowtriangle_right_fill,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 20),
                      child: Text(
                        '資料來源：${municipalityList[currentIndex].dataSource}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(155, 155, 155, 1),
                        ),
                      ),
                    ),
                    carousel.CarouselSlider(
                      options: carousel.CarouselOptions(
                        autoPlay: true,
                        viewportFraction: 1,
                        autoPlayInterval: const Duration(seconds: 3),
                        height: 175,
                        onPageChanged: (index, _) {
                          controller.onPageChanged(index);
                        },
                      ),
                      items: items,
                      carouselController: carouselController,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          AnalyticsHelper.logElectionEvent(eventName: 'to_2022Election');
                          launchUrlString(controller.readmoreUrl);
                        },
                        child: const Text(
                          '查看更多',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Color.fromRGBO(74, 74, 74, 1),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (lastUpdateTime != null)
                      Text(
                        '最後更新時間 ${DateFormat('yyyy/MM/dd HH:mm').format(lastUpdateTime)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(155, 155, 155, 1),
                        ),
                      ),
                  ],
                ),
              ),
            )
          ],
        );
      });
  }
}
