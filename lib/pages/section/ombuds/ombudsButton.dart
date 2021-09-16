import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tv/helpers/dataConstants.dart';

class OmbudsButton extends StatelessWidget {
  final double width;
  final String imageLocationString;
  final String title1;
  final String title2;
  final GestureTapCallback? onTap;
  OmbudsButton({
    required this.width,
    required this.imageLocationString,
    required this.title1,
    required this.title2,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(
        children: [
          Container(
            width: width,
            height: 36,
            color: Color(0xff003366),
            child: SvgPicture.asset(
              imageLocationString,
              color: Color.fromARGB(255, 255, 204, 1),
            ),
          ),
          Container(
            width: width,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    title1,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: themeColor,
                        height: 1.7),
                  ),
                  Text(
                    title2,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: themeColor,
                        height: 1.7),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
