import 'package:flutter/material.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/widgets/error/mNewsErrorWidget.dart';

class Error400Widget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MNewsErrorWidget(
      assetImagePath: error400Png,
      title: '這個頁面失去訊號了...',
      buttonName: '回首頁',
      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
    );
  }
}