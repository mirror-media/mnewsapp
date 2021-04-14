import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/widgets/story/parseTheTextToHtmlWidget.dart';

class BlockQuoteWidget extends StatelessWidget {
  final String content;
  BlockQuoteWidget({
    @required this.content,
  });

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