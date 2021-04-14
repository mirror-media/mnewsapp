import 'package:flutter/material.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/widgets/story/quoteByFrameClipper.dart';

class QuoteByWidget extends StatelessWidget {
  final String quote;
  final String quoteBy;
  QuoteByWidget({
    @required this.quote,
    this.quoteBy,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            quote,
            style: TextStyle(
              fontSize: 20,
              height: 1.8,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: ClipPath(
              clipper: QuoteByTopFrameClipper(),
              child: Container(
                height: width/8,
                width: width/8,
                decoration: BoxDecoration(
                  color: quotebyColor,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '—— $quoteBy',
                style: TextStyle(
                  fontSize: 18,
                  color: quotebyColor,
                ),
              ),
              SizedBox(width: 8.0),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: ClipPath(
                  clipper: QuoteByBottomFrameClipper(),
                  child: Container(
                    height: width/8,
                    width: width/8,
                    decoration: BoxDecoration(
                      color: quotebyColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]
    );
  }
}
