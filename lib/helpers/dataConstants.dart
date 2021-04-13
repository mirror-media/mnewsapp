import 'package:flutter/material.dart';
import 'package:tv/models/section.dart';

/// assets
const String menuJson = 'assets/json/menu.json';
const String defaultNotificationListJson = 'assets/json/defaultNotificationList.json';
const String error400Png = 'assets/image/error404.png';
const String error500Png = 'assets/image/error500.png';
const String noSignalPng = 'assets/image/noSignal.png';

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

/// section
enum MNewsSection {
  news,
  live,
  video,
  show,
  anchorperson
}

const mNewsSectionList = [
  {
    Section.idKey: MNewsSection.news,
    Section.nameKey: '新聞'
  },
  {
    Section.idKey: MNewsSection.live,
    Section.nameKey: '直播'
  },
  {
    Section.idKey: MNewsSection.video,
    Section.nameKey: '影音'
  },
  {
    Section.idKey: MNewsSection.show,
    Section.nameKey: '節目'
  },
  {
    Section.idKey: MNewsSection.anchorperson,
    Section.nameKey: '鏡主播'
  }
];

/// live
const String mNewsLiveYoutubeId = 'coYw-eVU0Ks';
const String mNewsLiveSiteYoutubePlayListId = 'PLT6yxVwBEbi2dWegLu37V63_tP-nI6em_';