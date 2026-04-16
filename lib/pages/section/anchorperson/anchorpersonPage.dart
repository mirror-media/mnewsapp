import 'package:flutter/material.dart';
import 'package:tv/bindings/anchorperson_binding.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/pages/section/anchorperson/anchorpersonListWidget.dart';

class AnchorpersonPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.sendScreenView(screenName: 'AnchorpersonPage');
    AnchorpersonBinding().dependencies();
    return AnchorpersonListWidget();
  }
}
