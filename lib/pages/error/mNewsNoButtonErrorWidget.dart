import 'package:flutter/material.dart';

class MNewsNoButtonErrorWidget extends StatelessWidget {
  final String assetImagePath;
  final String title;
  final bool isColumn;
  MNewsNoButtonErrorWidget({
    required this.assetImagePath,
    required this.title,
    this.isColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    if(isColumn) {
      return Column(
        children: [
          SizedBox(height: 200),
          Center(child: Image.asset(assetImagePath)),
          SizedBox(height: 16),
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                color: Color(0xff757575),
              ),
            ),
          ),
          SizedBox(height: 36),
        ],
      );
    }
    return ListView(
      children: [
        SizedBox(height: 200),
        Center(child: Image.asset(assetImagePath)),
        SizedBox(height: 16),
        Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 17,
              color: Color(0xff757575),
            ),
          ),
        ),
        SizedBox(height: 36),
      ],
    );
  }
}