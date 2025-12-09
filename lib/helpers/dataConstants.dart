import 'package:flutter/material.dart';
import 'package:tv/models/baseModel.dart';

/// url link
const mNewsMail = 'mnews.cs@mnews.com.tw';
const youtubeLink = 'https://www.youtube.com/';
const ombudsLaw =
    'https://storage.googleapis.com/static-mnews-tw-prod/regulation/ombuds_law_20211123.pdf';

/// assets
const String menuJson = 'assets/json/menu.json';
const String videoMenuJson = 'assets/json/videoMenu.json';
const String defaultNotificationListJson =
    'assets/json/defaultNotificationList.json';
const String tabContentNoResultSvg = 'assets/image/tabContentNoResult.svg';
const String error400Png = 'assets/image/error404.png';
const String error500Png = 'assets/image/error500.png';
const String noSignalPng = 'assets/image/noSignal.png';
const String searchNoResultSvg = 'assets/image/search/searchNoResult.svg';
const String ombudsDefaultJpg = 'assets/image/ombuds/ombudsDefault.jpg';
const String tvSvg = 'assets/image/ombuds/tv.svg';
const String phoneSvg = 'assets/image/ombuds/phone.svg';
const String paperSvg = 'assets/image/ombuds/paper.svg';
const String faqSvg = 'assets/image/ombuds/FAQ.svg';
const String mailSvg = 'assets/image/ombuds/mail.svg';
const String logoPng = 'assets/image/logo.png';
const String hammerSvg = 'assets/image/ombuds/hammer.svg';
const String adUnitIdJson = 'assets/json/adUnitId.json';
const String reportSvg = 'assets/image/ombuds/report.svg';
const String downloadSvg = 'assets/image/download.svg';
const String speakerSvg = 'assets/image/ombuds/speaker.svg';
const String mnewsAdEntry = 'assets/image/mnews_ad_entry.gif';

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
  ombuds,
  programList,
  topicList,
}

const mNewsDevSectionList = [
  {BaseModel.idKey: MNewsSection.news, BaseModel.nameKey: '新聞'},
  {BaseModel.idKey: MNewsSection.live, BaseModel.nameKey: '直播'},
  {BaseModel.idKey: MNewsSection.video, BaseModel.nameKey: '影音'},
  {BaseModel.idKey: MNewsSection.show, BaseModel.nameKey: '節目'},
  {BaseModel.idKey: MNewsSection.anchorperson, BaseModel.nameKey: '鏡主播'},
  {BaseModel.idKey: MNewsSection.ombuds, BaseModel.nameKey: '公評人'},
  {BaseModel.idKey: MNewsSection.programList, BaseModel.nameKey: '節目表'},
  {BaseModel.idKey: MNewsSection.topicList, BaseModel.nameKey: '專題'}
];

const mNewsProdSectionList = [
  {BaseModel.idKey: MNewsSection.news, BaseModel.nameKey: '新聞'},
  {BaseModel.idKey: MNewsSection.live, BaseModel.nameKey: '直播'},
  {BaseModel.idKey: MNewsSection.video, BaseModel.nameKey: '影音'},
  {BaseModel.idKey: MNewsSection.show, BaseModel.nameKey: '節目'},
  {BaseModel.idKey: MNewsSection.anchorperson, BaseModel.nameKey: '鏡主播'},
  {BaseModel.idKey: MNewsSection.ombuds, BaseModel.nameKey: '公評人'},
  {BaseModel.idKey: MNewsSection.programList, BaseModel.nameKey: '節目表'},
  {BaseModel.idKey: MNewsSection.topicList, BaseModel.nameKey: '專題'}
];

/// live
const String mNewsLiveYoutubeId = 'coYw-eVU0Ks';
const String mNewsLiveSiteYoutubePlayListId =
    'PLT6yxVwBEbi2dWegLu37V63_tP-nI6em_';

/// google admob
const androidAdMobAppId = 'ca-app-pub-3940256099942544~3347511713';
const androidAnchoredBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
const androidInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
const iOSAdMobAppId = 'ca-app-pub-3940256099942544~1458002511';
const iOSAnchoredBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';
const iOSInterstitialAdUnitId = 'ca-app-pub-3940256099942544/4411468910';

// slug filter
const filteredSlug = [
  'privacy',
  'ad-sales',
  'press-self-regulation',
  'webauthorization',
  'aboutus',
];

//election
const kmtLogoSvg = 'assets/image/election/kmt.svg';
const dppLogoSvg = 'assets/image/election/dpp.svg';
const noPartySvg = 'assets/image/election/noParty.svg';
const electedSvg = 'assets/image/election/elected.svg';

const Map<String, String> partyLogoMap = {
  '國民黨': kmtLogoSvg,
  '中國國民黨': kmtLogoSvg,
  '民進黨': dppLogoSvg,
  '民主進步黨': dppLogoSvg,
  '無黨籍': noPartySvg,
  '無': noPartySvg,
};

