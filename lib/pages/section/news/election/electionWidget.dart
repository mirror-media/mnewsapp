import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tv/blocs/election/election_cubit.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/models/election/municipality.dart';
import 'package:tv/pages/section/news/election/municipalityItem.dart';

import 'package:url_launcher/url_launcher_string.dart';

class ElectionWidget extends StatefulWidget {
  ElectionWidget({Key? key}) : super(key: key);

  @override
  State<ElectionWidget> createState() => _ElectionWidgetState();
}

class _ElectionWidgetState extends State<ElectionWidget> {
  List<Municipality> municipalityList = [];
  late DateTime lastUpdateTime;
  final CarouselController carouselController = CarouselController();
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  late final Timer? autoUpdateTimer;
  int currentIndex = 0;
  late final String api;
  late final String readmoreUrl;
  late final DateTime startShowTime;
  late final DateTime endShowTime;

  @override
  void initState() {
    var electionJsonString = remoteConfig.getString('election');
    try {
      var electionJson = jsonDecode(electionJsonString);
      api = electionJson['api'];
      readmoreUrl = electionJson['readMoreUrl'];
      startShowTime = DateTime.parse(electionJson['startTime']);
      endShowTime = DateTime.parse(electionJson['endTime']);
      fetchMunicipalityData();
      autoUpdateTimer = Timer.periodic(
          const Duration(minutes: 1), (timer) => fetchMunicipalityData());
    } catch (e) {
      print('Init election widget error: $e');
      autoUpdateTimer = null;
      context.read<ElectionCubit>().hideWidget();
    }

    super.initState();
  }

  @override
  void dispose() {
    autoUpdateTimer?.cancel();
    super.dispose();
  }

  void fetchMunicipalityData() {
    var now = DateTime.now();
    if (now.isBefore(startShowTime) || now.isAfter(endShowTime)) {
      context.read<ElectionCubit>().hideWidget();
    } else {
      context.read<ElectionCubit>().fetchMunicipalityData(api);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ElectionCubit, ElectionState>(
      builder: (context, state) {
        if (state is HideWidget) {
          return const SizedBox();
        }

        if (state is ElectionDataLoaded) {
          municipalityList = state.municipalityList;
          lastUpdateTime = state.lastUpdateTime;
        }

        if (municipalityList.isEmpty) {
          return const SizedBox();
        }

        List<Widget> items = [];
        for (var item in municipalityList) {
          items.add(MunicipalityItem(item));
        }

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
                            AnalyticsHelper.logElectionEvent(
                                eventName: 'country_button');
                            carouselController.previousPage();
                          },
                          child: Icon(
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
                            AnalyticsHelper.logElectionEvent(
                                eventName: 'country_button');
                            carouselController.nextPage();
                          },
                          child: Icon(
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
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(155, 155, 155, 1),
                        ),
                      ),
                    ),
                    CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        viewportFraction: 1,
                        autoPlayInterval: const Duration(seconds: 3),
                        height: 175,
                        onPageChanged: (index, reason) {
                          setState(() {
                            currentIndex = index;
                          });
                        },
                      ),
                      items: items,
                      carouselController: carouselController,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          AnalyticsHelper.logElectionEvent(
                              eventName: 'to_2022Election');
                          launchUrlString(readmoreUrl);
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
                    const SizedBox(
                      height: 8,
                    ),
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
      },
    );
  }
}
