import 'package:flutter/material.dart';

class MNewsErrorWidget extends StatelessWidget {
  final String assetImagePath;
  final String title;
  final String buttonName;
  final VoidCallback? onPressed;
  MNewsErrorWidget({
    required this.assetImagePath,
    required this.title,
    required this.buttonName,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
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