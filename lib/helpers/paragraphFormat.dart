import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/content.dart';
import 'package:tv/models/paragraph.dart';
import 'package:flutter_embedded_webview/flutter_embedded_webview.dart';
import 'package:tv/widgets/story/annotationWidget.dart';
import 'package:tv/widgets/story/blockQuoteWidget.dart';
import 'package:tv/widgets/story/imageAndDescriptionSlideShowWidget.dart';
import 'package:tv/widgets/story/imageDescriptionWidget.dart';
import 'package:tv/widgets/story/infoBoxWidget.dart';
import 'package:tv/widgets/story/mNewsAudioPlayer.dart';
import 'package:tv/widgets/story/mNewsVideoPlayer.dart';
import 'package:tv/widgets/story/parseTheTextToHtmlWidget.dart';
import 'package:tv/widgets/story/quoteByWidget.dart';
import 'package:tv/widgets/youtube/youtubeWidget.dart';

class ParagraphFormat {
  Widget parseTheParagraph(
      Paragraph? paragraph, BuildContext context, double textSize,
      {List<String>? imageUrlList}) {
    if (paragraph == null) {
      return Container();
    }

    switch (paragraph.type) {
      case 'header-one':
        {
          if (paragraph.contents!.length > 0) {
            return ParseTheTextToHtmlWidget(
              html: '<h1>' + paragraph.contents![0].data + '</h1>',
              fontSize: textSize,
            );
          }
          return Container();
        }
      case 'header-two':
        {
          if (paragraph.contents!.length > 0) {
            return ParseTheTextToHtmlWidget(
              html: '<h2>' + paragraph.contents![0].data + '</h2>',
              fontSize: textSize,
            );
          }
          return Container();
        }
      case 'code-block':
      case 'unstyled':
        {
          if (paragraph.contents!.length > 0) {
            return ParseTheTextToHtmlWidget(
              html: paragraph.contents![0].data,
              fontSize: textSize,
            );
          }
          return Container();
        }
      case 'ordered-list-item':
        {
          return buildOrderListWidget(paragraph.contents!, textSize);
        }
      case 'unordered-list-item':
        {
          return buildUnorderListWidget(paragraph.contents!, textSize);
        }
      case 'image':
        {
          var width = MediaQuery.of(context).size.width - 48;
          if (paragraph.contents!.length > 0) {
            return ImageDescriptionWidget(
              imageUrl: paragraph.contents![0].data,
              description: paragraph.contents![0].description,
              width: width,
              textSize: textSize - 4,
              imageUrlList: imageUrlList ?? [paragraph.contents![0].data],
            );
          }

          return Container();
        }
      case 'slideshow':
        {
          return ImageAndDescriptionSlideShowWidget(
            contentList: paragraph.contents!,
            textSize: textSize,
            imageUrlList: imageUrlList ?? [],
          );
        }
      case 'annotation':
        {
          if (paragraph.contents!.length > 0) {
            return AnnotationWidget(
              data: paragraph.contents![0].data,
              textSize: textSize,
            );
          }
          return Container();
        }
      case 'blockquote':
        {
          if (paragraph.contents!.length > 0) {
            return BlockQuoteWidget(
              content: paragraph.contents![0].data,
              textSize: textSize,
            );
          }
          return Container();
        }
      case 'quoteby':
        {
          if (paragraph.contents!.length > 0) {
            return QuoteByWidget(
              quote: paragraph.contents![0].data,
              quoteBy: paragraph.contents![0].description,
              textSize: textSize,
            );
          }
          return Container();
        }
      case 'infobox':
        {
          if (paragraph.contents!.length > 0) {
            return InfoBoxWidget(
              title: paragraph.contents![0].description ?? '',
              description: paragraph.contents![0].data,
              textSize: textSize,
            );
          }
          return Container();
        }
      case 'video':
        {
          if (paragraph.contents!.length > 0) {
            return MNewsVideoPlayer(
              videourl: paragraph.contents![0].data,
              aspectRatio: 16 / 9,
            );
          }
          return Container();
        }
      case 'audio':
        {
          if (paragraph.contents!.length > 0) {
            String? titleAndDescription;
            if (paragraph.contents![0].description != null) {
              titleAndDescription =
                  paragraph.contents![0].description!.split(';')[0];
            }

            return MNewsAudioPlayer(
              audioUrl: paragraph.contents![0].data,
              title: titleAndDescription,
              textSize: textSize,
            );
          }
          return Container();
        }
      case 'youtube':
        {
          if (paragraph.contents!.length > 0) {
            var splitList = paragraph.contents![0].data.split(': ');
            String id = splitList[1].split(',')[0];
            var description = splitList[2].split('}')[0];
            return YoutubeWidget(
              youtubeId: id,
              description: description,
              textSize: textSize,
            );
          }
          return Container();
        }
      case 'embeddedcode':
        {
          if (paragraph.contents!.length > 0) {
            return EmbeddedCodeWidget(
              embeddedCode: paragraph.contents![0].data,
              aspectRatio: paragraph.contents![0].aspectRatio,
            );
          }
          return Container();
        }
      default:
        {
          return Container();
        }
    }
  }

  List<String?> _convertStrangeDataList(List<Content> contentList) {
    List<String?> resultList = List.empty(growable: true);
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

  Widget buildOrderListWidget(List<Content> contentList, double textSize) {
    List<String?> dataList = _convertStrangeDataList(contentList);

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
                fontSize: textSize,
                height: 1.8,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
                child: ParseTheTextToHtmlWidget(
                    html: dataList[index], fontSize: textSize)),
          ],
        );
      },
    );
  }

  Widget buildUnorderListWidget(List<Content> contentList, double textSize) {
    List<String?> dataList = _convertStrangeDataList(contentList);

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
            Expanded(
                child: ParseTheTextToHtmlWidget(
              html: dataList[index],
              fontSize: textSize,
            )),
          ],
        );
      },
    );
  }
}
