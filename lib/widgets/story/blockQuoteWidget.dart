import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/widgets/story/parseTheTextToHtmlWidget.dart';

class BlockQuoteWidget extends StatelessWidget {
  final String content;
  final double textSize;
  BlockQuoteWidget({required this.content, this.textSize = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.rotate(
          angle: 180 * math.pi / 180,
          child: Icon(
            Icons.format_quote,
            size: 60,
            color: blockquoteColor,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: ParseTheTextToHtmlWidget(
            html: content,
            color: blockquoteColor,
            fontSize: textSize,
          ),
        ),
        SizedBox(width: 8),
        Icon(
          Icons.format_quote,
          size: 60,
          color: blockquoteColor,
        ),
      ],
    );
  }
}
