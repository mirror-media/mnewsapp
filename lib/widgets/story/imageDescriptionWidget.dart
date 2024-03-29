import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/widgets/imageViewerWidget.dart';

class ImageDescriptionWidget extends StatelessWidget {
  final String imageUrl;
  final String? description;
  final double width;
  final double aspectRatio;
  final double textSize;
  final List<String> imageUrlList;
  ImageDescriptionWidget({
    required this.imageUrl,
    required this.description,
    required this.width,
    this.aspectRatio = 16 / 9,
    this.textSize = 16,
    required this.imageUrlList,
  });

  @override
  Widget build(BuildContext context) {
    double height = width / aspectRatio;

    return InkWell(
      child: Wrap(
        //direction: Axis.vertical,
        children: [
          if (imageUrl != '')
            CachedNetworkImage(
              //height: imageHeight,
              width: width,
              imageUrl: imageUrl,
              placeholder: (context, url) => Container(
                height: height,
                width: width,
                color: Colors.grey,
              ),
              errorWidget: (context, url, error) => Container(
                height: height,
                width: width,
                color: Colors.grey,
                child: Icon(Icons.error),
              ),
              fit: BoxFit.cover,
            ),
          if (description != null && description != '')
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                description!,
                style: TextStyle(fontSize: textSize, color: Colors.grey),
              ),
            ),
        ],
      ),
      onTap: () {
        int index = imageUrlList.indexOf(imageUrl);
        if (index == -1) {
          index = 0;
        }
        Get.to(() => ImageViewerWidget(
              imageUrlList,
              openIndex: index,
            ));
      },
    );
  }
}
