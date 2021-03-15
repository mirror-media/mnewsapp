import 'package:flutter/material.dart';
import 'package:tv/models/section.dart';

/// color
const Color appBarColor = Color(0xff003366);
const Color tabBarColor = Color(0xffF4F5F6);
const Color tabBarSelectedColor = Color(0xff003366);
const Color tabBarUnselectedColor = Colors.grey;
const Color drawerColor = Color(0xff004DBC);
const Color editorChoiceTagColor = Color(0xff003366);
const Color editorChoiceTitleBackgroundColor = Color(0xff004DBC);
const Color newsMarqueeLeadingColor = Color(0xffFFCC00);
const Color newsMarqueeContentColor = Color(0xff003366);

/// section
enum MNewsSection {
  news,
  live,
  media,
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
    Section.idKey: MNewsSection.media,
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