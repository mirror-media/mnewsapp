import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tv/blocs/section/section_cubit.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/topic.dart';
import 'package:tv/pages/search/searchPage.dart';
import 'package:tv/pages/section/anchorperson/anchorpersonPage.dart';
import 'package:tv/pages/section/live/livePage.dart';
import 'package:tv/pages/section/news/newsPage.dart';
import 'package:tv/pages/section/ombuds/ombudsPage.dart';
import 'package:tv/pages/section/programList/programListPage.dart';
import 'package:tv/pages/section/show/showPage.dart';
import 'package:tv/pages/section/topic/topicListPage.dart';
import 'package:tv/pages/section/video/videoPage.dart';
import 'package:tv/widgets/gDPR.dart';
import 'package:tv/widgets/homeDrawer.dart';

class HomePage extends StatefulWidget {
  final List<Topic> topics;
  const HomePage(this.topics);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _scaffoldkey = GlobalKey<ScaffoldState>();
  // InterstitialAdWidget interstitial = InterstitialAdWidget();

  @override
  void initState() {
    _showGDPR();
    super.initState();
  }

  _showGDPR() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstLaunch = prefs.getBool("isFirstLaunch");
    if (isFirstLaunch == null || isFirstLaunch) {
      await Future.delayed(Duration(seconds: 1));
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(0.0),
            content: GDPR(),
          );
        },
      );
      await prefs.setBool("isFirstLaunch", false);
      // } else {
      //   interstitial.createInterstitialAd();
      //   await Future.delayed(Duration(seconds: 1));
      //   interstitial.showInterstitialAd();
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      drawer: HomeDrawer(widget.topics),
      appBar: _buildBar(context, _scaffoldkey),
      body: BlocBuilder<SectionCubit, SectionStateCubit>(
          builder: (BuildContext context, SectionStateCubit state) {
        if (state is SectionError) {
          final error = state.error;
          print('SectionError: ${error.message}');
          return Container();
        } else {
          MNewsSection sectionId = state.sectionId;
          return Column(
            children: [
              Expanded(
                child: _buildBody(sectionId),
              ),
              // AnchoredBannerAdWidget(),
            ],
          );
        }
      }),
    );
  }

  PreferredSizeWidget _buildBar(
      BuildContext context, GlobalKey<ScaffoldState> scaffoldkey) {
    return AppBar(
      elevation: 0.1,
      leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => scaffoldkey.currentState!.openDrawer()),
      backgroundColor: appBarColor,
      centerTitle: true,
      title: Image(
        image: AssetImage(logoPng),
        width: 120,
        height: 36,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          tooltip: 'Search',
          onPressed: () => Get.to(() => SearchPage()),
        ),
      ],
    );
  }

  Widget _buildBody(MNewsSection sectionId) {
    switch (sectionId) {
      case MNewsSection.news:
        return NewsPage();
      case MNewsSection.live:
        return LivePage();
      case MNewsSection.video:
        return VideoPage();
      case MNewsSection.show:
        return ShowPage();
      case MNewsSection.anchorperson:
        return AnchorpersonPage();
      case MNewsSection.ombuds:
        return OmbudsPage();
      case MNewsSection.programList:
        return ProgramListPage();
      case MNewsSection.topicList:
        return TopicListPage();
    }
  }
}
