import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:tv/helpers/dataConstants.dart';

class InfoBoxWidget extends StatelessWidget {
  final String title;
  final String description;
  InfoBoxWidget({
    required this.title,
    required this.description,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  color: infoBoxTitleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            HtmlWidget(
              description,
              hyperlinkColor: Colors.blue[900],
              textStyle: TextStyle(
                fontSize: 20,
                height: 1.8,
                //color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
