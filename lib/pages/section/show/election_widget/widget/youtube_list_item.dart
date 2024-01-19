import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/helpers/dateTimeFormat.dart';
import 'package:tv/models/youtubePlaylistItem.dart';

class YoutubeListItem extends StatelessWidget {
  const YoutubeListItem({required this.item, required this.itemClickEvent});

  final YoutubePlaylistItem item;
  final Function() itemClickEvent;

  @override
  Widget build(BuildContext context) {
    double imageWidth = 33.3 * (Get.width - 48) / 100;
    double imageHeight = imageWidth / 16 * 9;
    DateTimeFormat dateTimeFormat = DateTimeFormat();
    final TextScaleFactorController textScaleFactorController = Get.find();
    return InkWell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedNetworkImage(
            height: imageHeight,
            width: imageWidth,
            imageUrl: item.photoUrl,
            placeholder: (context, url) => Container(
              height: imageHeight,
              width: imageWidth,
              color: Colors.grey,
            ),
            errorWidget: (context, url, error) => Container(
              height: imageHeight,
              width: imageWidth,
              color: Colors.grey,
              child: Icon(Icons.error),
            ),
            fit: BoxFit.cover,
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => ExtendedText(
                    item.name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textScaler: TextScaler.linear(
                        textScaleFactorController.textScaleFactor.value),
                  ),
                ),
                if (item.publishedAt != null) ...[
                  SizedBox(height: 12),
                  Text(
                    dateTimeFormat.changeStringToDisplayString(
                        item.publishedAt!,
                        'yyyy-MM-ddTHH:mm:ssZ',
                        'yyyy年MM月dd日'),
                    style: TextStyle(
                      color: Color(0xff757575),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      onTap: () {
        itemClickEvent();
      },
    );
  }
}
