import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tv/controller/app_shell_controller.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/pages/changeFontSizePage.dart';
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
  final String appVersion;
  const HomePage({required this.appVersion});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _scaffoldkey = GlobalKey<ScaffoldState>();
  final appShellController = Get.find<AppShellController>();

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      drawer: HomeDrawer(widget.appVersion),
      appBar: _buildBar(context, _scaffoldkey),
      body: Obx(() => _buildBody(appShellController.currentSection.value)),
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
          icon: Icon(Icons.font_download),
          tooltip: '更改字體大小',
          onPressed: () => Get.to(() => ChangeFontSizePage()),
        ),
        IconButton(
          icon: Icon(Icons.search),
          tooltip: '搜尋',
          onPressed: () => Get.to(() => SearchPage()),
        ),
      ],
    );
  }

  Widget _buildBody(MNewsSection sectionId) {
    switch (sectionId) {
      case MNewsSection.news:
        return const NewsPage();
      case MNewsSection.live:
        return LivePage();
      case MNewsSection.video:
        return VideoPage();
      case MNewsSection.show:
        return const ShowPage();
      case MNewsSection.anchorperson:
        return AnchorpersonPage();
      case MNewsSection.ombuds:
        return const OmbudsPage();
      case MNewsSection.programList:
        return ProgramListPage();
      case MNewsSection.topicList:
        return TopicListPage();
    }
  }
}
