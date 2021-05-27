import 'package:flutter/material.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/pages/error/mNewsErrorWidget.dart';

class Error500Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MNewsErrorWidget(
      assetImagePath: error500Png,
      title: '抱歉...訊號出了點問題',
      buttonName: '回首頁',
      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
    );
  }
}