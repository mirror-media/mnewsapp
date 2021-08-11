import 'package:flutter/material.dart';

class MNewsErrorWidget extends StatelessWidget {
  final String assetImagePath;
  final String title;
  final String buttonName;
  final VoidCallback? onPressed;
  final bool isColumn;
  MNewsErrorWidget({
    required this.assetImagePath,
    required this.title,
    required this.buttonName,
    this.onPressed,
    this.isColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    if(isColumn) {
      return Column(
        children: [
          SizedBox(height: height/3),
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
          Padding(
            padding: EdgeInsets.only(left: width/3, right: width/3),
            child: OutlinedButton(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 16.0),
                child: Text(
                  buttonName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                  TextStyle(
                    color: Color(0xff014DB8),
                  ),
                ),
                side: MaterialStateProperty.all(
                  BorderSide(
                    color: Color(0xff014DB8),
                  ),
                ),
              ),
              onPressed: onPressed
            ),
          ),
        ],
      );
    }
    return ListView(
      children: [
        SizedBox(height: height/4.5),
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
        Padding(
          padding: EdgeInsets.only(left: width/3, right: width/3),
          child: OutlinedButton(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 16.0),
              child: Text(
                buttonName,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            style: ButtonStyle(
              textStyle: MaterialStateProperty.all(
                TextStyle(
                  color: Color(0xff014DB8),
                ),
              ),
              side: MaterialStateProperty.all(
                BorderSide(
                  color: Color(0xff014DB8),
                ),
              ),
            ),
            onPressed: onPressed
          ),
        ),
      ],
    );
  }
}