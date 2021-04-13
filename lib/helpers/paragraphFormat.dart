import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/contentList.dart';
import 'package:tv/models/paragraph.dart';
import 'package:tv/widgets/story/parseTheTextToHtmlWidget.dart';

class ParagraphFormat {
  Widget parseTheParagraph(Paragraph paragraph, BuildContext context) {
    switch (paragraph.type) {
      case 'header-one':
        {
          if (paragraph.contents.length > 0) {
            return ParseTheTextToHtmlWidget(
              html: '<h1>' + paragraph.contents[0].data + '</h1>'
            );
          }
          return Container();
        }
      case 'header-two':
        {
          if (paragraph.contents.length > 0) {
            return ParseTheTextToHtmlWidget(
              html: '<h2>' + paragraph.contents[0].data + '</h2>'
            );
          }
          return Container();
        }
      case 'code-block':
      case 'unstyled':
        {
          if (paragraph.contents.length > 0) {
            return ParseTheTextToHtmlWidget(
              html: paragraph.contents[0].data
            );
          }
          return Container();
        }
      case 'ordered-list-item':
        {
          return buildOrderListWidget(paragraph.contents);
        }
        break;
      case 'unordered-list-item':
        {
          return buildUnorderListWidget(paragraph.contents);
        }
        break;
      default:
        {
          return Container();
        }
        break;
    }
  }

  List<String> _convertStrangedataList(ContentList contentList) {
    List<String> resultList = List<String>();
    if (contentList.length == 1 && contentList[0].data[0] == '[') {
      // api data is strange [[...]]
      String dataString =
          contentList[0].data.substring(1, contentList[0].data.length - 1);
      resultList = dataString.split(', ');
    } else {
      contentList.forEach((content) {
        resultList.add(content.data);
      });
    }
    return resultList;
  }

  Widget buildOrderListWidget(ContentList contentList) {
    List<String> dataList = _convertStrangedataList(contentList);

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (index + 1).toString() + '.',
              style: TextStyle(
                fontSize: 20,
                height: 1.8,
              ),
            ),
            SizedBox(width: 16),
            Expanded(child: ParseTheTextToHtmlWidget(html: dataList[index])),
          ],
        );
      },
    );
  }

  Widget buildUnorderListWidget(ContentList contentList) {
    List<String> dataList = _convertStrangedataList(contentList);

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: storyWidgetColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(child: ParseTheTextToHtmlWidget(html: dataList[index])),
          ],
        );
      },
    );
  }
}