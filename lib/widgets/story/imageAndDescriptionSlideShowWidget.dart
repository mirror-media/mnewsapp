import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/content.dart';
import 'package:tv/widgets/imageViewerWidget.dart';

class ImageAndDescriptionSlideShowWidget extends StatefulWidget {
  final List<Content> contentList;
  final double textSize;
  final List<String> imageUrlList;

  const ImageAndDescriptionSlideShowWidget({
    super.key,
    required this.contentList,
    this.textSize = 20,
    required this.imageUrlList,
  });

  @override
  State<ImageAndDescriptionSlideShowWidget> createState() =>
      _ImageAndDescriptionSlideShowWidgetState();
}

class _ImageAndDescriptionSlideShowWidgetState
    extends State<ImageAndDescriptionSlideShowWidget> {
  int currentPage = 1;
  late List<Content> contentList;
  late carousel_slider.CarouselOptions options;
  final imageCarouselController = carousel_slider.CarouselSliderController();
  final textCarouselController = carousel_slider.CarouselSliderController();
  late double textSize;

  final Widget backArrowWidget = Icon(
    Icons.arrow_back_ios,
    color: slideShowColor,
    size: 30,
  );

  final Widget forwardArrowWidget = Icon(
    Icons.arrow_forward_ios,
    color: slideShowColor,
    size: 30,
  );

  final Widget myVerticalDivider = Padding(
    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
    child: Container(
      color: Color(0xff757575),
      width: 1.8,
      height: 20,
    ),
  );

  @override
  void initState() {
    contentList = widget.contentList;
    textSize = widget.textSize;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ImageAndDescriptionSlideShowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    textSize = widget.textSize;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width - 48;
    double imageHeight = width / 16 * 9;
    options = carousel_slider.CarouselOptions(
      viewportFraction: 1,
      aspectRatio: 16 / 9,
      enlargeCenterPage: true,
      onPageChanged: (index, reason) {
        setState(() {
          currentPage = index + 1;
        });
      },
    );

    List<Widget> imageSilders = contentList
        .map(
          (content) => InkWell(
        onTap: () {
          int index = widget.imageUrlList.indexOf(content.data);
          if (index == -1) {
            index = 0;
          }
          Get.to(() => ImageViewerWidget(
            widget.imageUrlList,
            openIndex: index,
          ));
        },
        child: CachedNetworkImage(
          height: imageHeight,
          width: width,
          imageUrl: content.data,
          placeholder: (context, url) => Container(
            height: imageHeight,
            width: width,
            color: Colors.grey,
          ),
          errorWidget: (context, url, error) => Container(
            height: imageHeight,
            width: width,
            color: Colors.grey,
            child: Icon(Icons.error),
          ),
          fit: BoxFit.fitHeight,
        ),
      ),
    )
        .toList();

    return Column(
      children: [
        carousel_slider.CarouselSlider(
          items: imageSilders,
          carouselController: imageCarouselController,
          options: options,
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              child: backArrowWidget,
              onTap: () {
                imageCarouselController.previousPage();
                textCarouselController.previousPage();
              },
            ),
            Row(
              children: [
                Text(
                  currentPage.toString(),
                  style: TextStyle(
                    color: slideShowColor,
                    fontSize: textSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                myVerticalDivider,
                Text(
                  imageSilders.length.toString(),
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            InkWell(
              child: forwardArrowWidget,
              onTap: () {
                imageCarouselController.nextPage();
                textCarouselController.nextPage();
              },
            ),
          ],
        ),
        const SizedBox(height: 18),
        _buildTextCarouselSlider(textCarouselController),
      ],
    );
  }

  Widget _buildTextCarouselSlider(
      carousel_slider.CarouselSliderController carouselController) {
    final options = carousel_slider.CarouselOptions(
      height: 38,
      viewportFraction: 1,
      enlargeCenterPage: true,
      onPageChanged: (index, reason) {},
    );
    List<Widget> textSilders = contentList
        .map(
          (content) => RichText(
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        text: TextSpan(
          style: TextStyle(
            color: Color(0xff757575),
            fontSize: textSize - 5,
            fontWeight: FontWeight.w400,
          ),
          text: content.description,
        ),
      ),
    )
        .toList();

    return carousel_slider.CarouselSlider(
      items: textSilders,
      carouselController: carouselController,
      options: options,
    );
  }
}
