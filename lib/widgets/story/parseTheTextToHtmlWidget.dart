import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class ParseTheTextToHtmlWidget extends StatelessWidget {
  final String html;
  final Color color;
  final double fontSize;
  ParseTheTextToHtmlWidget({
    @required this.html,
    this.color,
    this.fontSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      html,
      hyperlinkColor: Colors.blue,
      textStyle: TextStyle(
        fontSize: fontSize,
        height: 1.8,
        color: color,
      ),
    );
  }
}