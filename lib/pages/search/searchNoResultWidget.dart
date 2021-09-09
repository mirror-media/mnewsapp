import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tv/helpers/dataConstants.dart';

class SearchNoResultWidget extends StatelessWidget {
  final String keyword;
  SearchNoResultWidget({
    required this.keyword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 60),
        SvgPicture.asset(searchNoResultSvg),
        SizedBox(height: 24),
        Text(
          '您的搜尋「$keyword」',
          style: TextStyle(color: Color(0xff898F9C), fontSize: 16.0),
        ),
        Text(
          '查無相關結果',
          style: TextStyle(color: Colors.black, fontSize: 16.0),
        ),
        SizedBox(height: 24),
      ],
    );
  }
}
