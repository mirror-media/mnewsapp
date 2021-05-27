import 'package:flutter/material.dart';
import 'package:tv/helpers/dataConstants.dart';

class TabContentNoResultWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        SizedBox(height: height/10),
        Center(child: Image.asset(tabContentNoResultPng)),
      ],
    );
  }
}