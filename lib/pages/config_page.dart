import 'package:flutter/material.dart';
import 'package:tv/helpers/dataConstants.dart';

class ConfigPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeColor,
      body: Center(
        child: Image.asset(logoPng, scale: 4.0),
      ),
    );
  }
}
