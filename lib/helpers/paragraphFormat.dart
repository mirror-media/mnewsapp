import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/contentList.dart';
import 'package:tv/models/paragraph.dart';
import 'package:tv/widgets/story/annotationWidget.dart';
import 'package:tv/widgets/story/blockQuoteWidget.dart';
import 'package:tv/widgets/story/imageDescriptionWidget.dart';
import 'package:tv/widgets/story/infoBoxWidget.dart';
import 'package:tv/widgets/story/parseTheTextToHtmlWidget.dart';
import 'package:tv/widgets/story/quoteByWidget.dart';

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
      case 'image':
        {
          var width = MediaQuery.of(context).size.width - 48;
          if(paragraph.contents.length > 0 &&
            paragraph.contents[0].data != null
          ) {
            return ImageDescriptionWidget(
              imageUrl: paragraph.contents[0].data,
              description: paragraph.contents[0].description,
              width: width,
            );
          }
          
          return Container();
        }
        break;
      case 'annotation':
        {
          if (paragraph.contents.length > 0) {
            return AnnotationWidget(data: paragraph.contents[0].data,);
          }
          return Container();
        }
        break;
      case 'blockquote':
        {
          if (paragraph.contents.length > 0) {
            return BlockQuoteWidget(content: paragraph.contents[0].data,);
          }
          return Container();
        }
        break;
      case 'quoteby':
        {
          if (paragraph.contents.length > 0) {
            return QuoteByWidget(
              quote: paragraph.contents[0].data,
              quoteBy: paragraph.contents[0].description,
            );
          }
          return Container();
        }
        break;
      case 'infobox':
        {
          if (paragraph.contents.length > 0) {
            return InfoBoxWidget(
              title: paragraph.contents[0].description,
              description: paragraph.contents[0].data,
            );
          }
          return Container();
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