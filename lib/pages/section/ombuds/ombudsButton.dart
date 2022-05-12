import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/helpers/dataConstants.dart';

class OmbudsButton extends StatelessWidget {
  final double width;
  final String imageLocationString;
  final String title1;
  final String title2;
  final GestureTapCallback? onTap;
  final double height;
  OmbudsButton({
    required this.width,
    required this.imageLocationString,
    required this.title1,
    required this.title2,
    required this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final TextScaleFactorController textScaleFactorController = Get.find();
    return InkWell(
      child: Column(
        children: [
          Container(
            width: width,
            height: 36,
            color: Color(0xff003366),
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: SvgPicture.asset(
              imageLocationString,
              color: Color.fromARGB(255, 255, 204, 1),
            ),
          ),
          Container(
            width: width,
            height: height - 36,
            color: Colors.white,
            padding: const EdgeInsets.all(8.0),
            child: Obx(
              () => AutoSizeText(
                '$title1\n$title2',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: themeColor,
                ),
                textScaleFactor:
                    textScaleFactorController.textScaleFactor.value,
              ),
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
