import 'package:flutter/material.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/widgets/error/mNewsErrorWidget.dart';

class NoSignalWidget extends StatelessWidget {
  final VoidCallback onPressed;
  NoSignalWidget({
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MNewsErrorWidget(
      assetImagePath: noSignalPng,
      title: '沒有網際網路連線',
      buttonName: '重新整理',
      onPressed: onPressed,
    );
  }
}