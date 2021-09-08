import 'package:flutter/material.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/pages/error/mNewsErrorWidget.dart';
import 'package:tv/pages/error/mNewsNoButtonErrorWidget.dart';

class Error400Widget extends StatelessWidget {
  final bool isNoButton;
  final bool isColumn;
  Error400Widget({
    this.isNoButton = false,
    this.isColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isNoButton) {
      return MNewsNoButtonErrorWidget(
        assetImagePath: error400Png,
        title: '抱歉...訊號出了點問題',
        isColumn: isColumn,
      );
    }

    return MNewsErrorWidget(
      assetImagePath: error400Png,
      title: '這個頁面失去訊號了...',
      buttonName: '回首頁',
      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
      isColumn: isColumn,
    );
  }
}
