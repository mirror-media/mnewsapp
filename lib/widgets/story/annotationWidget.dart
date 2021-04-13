import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/annotation.dart';

class AnnotationWidget extends StatefulWidget {
  final String data;
  AnnotationWidget({
    @required this.data,
  });

  @override
  _AnnotationWidgetState createState() => _AnnotationWidgetState();
}

class _AnnotationWidgetState extends State<AnnotationWidget> {
  List<String> displayStringList = List<String>();

  @override
  void initState() {
    _parsingTheData();
    super.initState();
  }

  _parsingTheData() {
    String temp = widget.data.replaceAll(RegExp(r'<!--[^{",}]*-->'), '');
    temp = temp.replaceAll('<!--', '<-split->').replaceAll('-->', '<-split->');
    displayStringList = temp.split('<-split->');
    for (int i = displayStringList.length - 1; i >= 0; i--) {
      if (displayStringList[i] == "") {
        displayStringList.removeAt(i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _renderWidgets(context),
    );
  }

  List<Widget> _renderWidgets(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    List<Widget> displayWidgets = List<Widget>();
    RegExp annotationExp = RegExp(
      r'__ANNOTATION__=(.*)',
      caseSensitive: false,
    );

    for (int i = 0; i < displayStringList.length; i++) {
      if (annotationExp.hasMatch(displayStringList[i])) {
        String body = annotationExp.firstMatch(displayStringList[i]).group(1);
        Annotation annotation = Annotation.parseResponseBody(body);
        if (annotation.isExpanded) {
          displayWidgets.add(
            HtmlWidget(
              annotation.text,
              hyperlinkColor: Colors.blue[900],
              textStyle: TextStyle(
                fontSize: 20,
                height: 1.8,
              ),
            ),
          );
          displayWidgets.add(
            InkWell(
              child: Wrap(
                children: [
                  SizedBox(width: 8),
                  Text(
                    '(註)',
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.8,
                      color: annotationColor,
                    ),
                  ),
                  SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 2.0, color: annotationColor),
                      ),
                      child: Icon(
                        Icons.arrow_drop_up,
                        color: annotationColor,
                        size: 18,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
              onTap: () {
                if (mounted) {
                  setState(() {
                    annotation.isExpanded = !annotation.isExpanded;
                    displayStringList[i] =
                        '__ANNOTATION__=' + json.encode(annotation.toJson());
                  });
                }
              },
            ),
          );
          displayWidgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Container(
                width: width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: annotationColor,
                      width: 3.0,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 15,
                      offset: Offset(0, 5), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: HtmlWidget(
                    annotation.annotation,
                    hyperlinkColor: Colors.blue[900],
                    textStyle: TextStyle(
                      fontSize: 20,
                      height: 1.8,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        // if is not expanded
        else {
          displayWidgets.add(
            HtmlWidget(
              annotation.text,
              hyperlinkColor: Colors.blue[900],
              textStyle: TextStyle(
                fontSize: 20,
                height: 1.8,
              ),
            ),
          );
          displayWidgets.add(
            InkWell(
              child: Wrap(
                children: [
                  SizedBox(width: 8),
                  Text(
                    '(註)',
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.8,
                      color: annotationColor,
                    ),
                  ),
                  SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 2.0, color: annotationColor),
                      ),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: annotationColor,
                        size: 18,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
              onTap: () {
                if (mounted) {
                  setState(() {
                    annotation.isExpanded = !annotation.isExpanded;
                    displayStringList[i] =
                        '__ANNOTATION__=' + json.encode(annotation.toJson());
                  });
                }
              },
            ),
          );
        }
      } else {
        displayWidgets.add(
          HtmlWidget(
            displayStringList[i],
            hyperlinkColor: Colors.blue[900],
            textStyle: TextStyle(
              fontSize: 20,
              height: 1.8,
            ),
          ),
        );
      }
    }
    return displayWidgets;
  }
}
