import 'package:flutter/material.dart';
import 'package:tv/models/baseModel.dart';

/// url link
const mNewsMail = 'mnews.cs@mnews.tw';
const mNewsWebsiteLink = 'https://dev.mnews.tw/';
const youtubeLink = 'https://www.youtube.com/';

/// assets
const String menuJson = 'assets/json/menu.json';
const String videoMenuJson = 'assets/json/videoMenu.json';
const String defaultNotificationListJson = 'assets/json/defaultNotificationList.json';
const String tabContentNoResultPng = 'assets/image/tabContentNoResult.png';
const String error400Png = 'assets/image/error404.png';
const String error500Png = 'assets/image/error500.png';
const String noSignalPng = 'assets/image/noSignal.png';
const String searchNoResultPng = 'assets/image/search/searchNoResult.png';
const String ombudsDefaultJpg = 'assets/image/ombuds/ombudsDefault.jpg';
const String tvPng = 'assets/image/ombuds/tv.png';
const String phonePng = 'assets/image/ombuds/phone.png';
const String paperPng = 'assets/image/ombuds/paper.png';
const String faqPng = 'assets/image/ombuds/FAQ.png';
const String mailPng = 'assets/image/ombuds/mail.png';

/// color
const Color themeColor = Color(0xff003366);
const Color appBarColor = Color(0xff003366);
const Color tabBarColor = Color(0xffF4F5F6);
const Color tabBarSelectedColor = Color(0xff003366);
const Color tabBarUnselectedColor = Colors.grey;
const Color drawerColor = Color(0xff004DBC);
const Color editorChoiceTagColor = Color(0xff003366);
const Color editorChoiceTitleBackgroundColor = Color(0xff004DBC);
const Color newsMarqueeLeadingColor = Color(0xffFFCC00);
const Color newsMarqueeContentColor = Color(0xff003366);

const Color storyWidgetColor = Color(0xff004DBC);
const Color storyBriefFrameColor = storyWidgetColor;
const Color storyBriefTextColor = storyWidgetColor;
const Color blockquoteColor = storyWidgetColor;
const Color quotebyColor = storyWidgetColor;
const Color annotationColor = storyWidgetColor;
const Color infoBoxTitleColor = storyWidgetColor;
const Color slideShowColor = storyWidgetColor;

/// section
enum MNewsSection {
  news,
  live,
  video,
  show,
  anchorperson,
  ombuds
}

const mNewsSectionList = [
  {
    BaseModel.idKey: MNewsSection.news,
    BaseModel.nameKey: '新聞'
  },
  {
    BaseModel.idKey: MNewsSection.live,
    BaseModel.nameKey: '直播'
  },
  {
    BaseModel.idKey: MNewsSection.video,
    BaseModel.nameKey: '影音'
  },
  {
    BaseModel.idKey: MNewsSection.show,
    BaseModel.nameKey: '節目'
  },
  {
    BaseModel.idKey: MNewsSection.anchorperson,
    BaseModel.nameKey: '鏡主播'
  },
  {
    BaseModel.idKey: MNewsSection.ombuds,
    BaseModel.nameKey: '公評人'
  }
];

/// live
const String mNewsLiveYoutubeId = 'coYw-eVU0Ks';
const String mNewsLiveSiteYoutubePlayListId = 'PLT6yxVwBEbi2dWegLu37V63_tP-nI6em_';