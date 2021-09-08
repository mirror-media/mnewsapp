import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/routeGenerator.dart';
import 'package:tv/models/storyListItem.dart';

class CarouselDisplayWidget extends StatelessWidget {
  final StoryListItem storyListItem;
  final double width;
  CarouselDisplayWidget({
    required this.storyListItem,
    required this.width,
  });

  final double aspectRatio = 16 / 9;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(
        children: [
          Stack(
            children: [
              _displayImage(width, storyListItem),
              Align(
                alignment: Alignment.topLeft,
                child: _displayTag(),
              ),
            ],
          ),
          Expanded(child: _displayTitle(storyListItem)),
        ],
      ),
      onTap: () {
        RouteGenerator.navigateToStory(context, storyListItem.slug);
      },
    );
  }

  Widget _displayImage(double width, StoryListItem storyListItem) {
    return CachedNetworkImage(
      height: width / aspectRatio,
      width: width,
      imageUrl: storyListItem.photoUrl,
      placeholder: (context, url) => Container(
        height: width / aspectRatio,
        width: width,
        color: Colors.grey,
      ),
      errorWidget: (context, url, error) => Container(
        height: width / aspectRatio,
        width: width,
        color: Colors.grey,
        child: Icon(Icons.error),
      ),
      fit: BoxFit.cover,
    );
  }

  Widget _displayTag() {
    return Container(
      decoration: BoxDecoration(
        color: editorChoiceTagColor,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: Text(
          '編輯精選',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _displayTitle(StoryListItem storyListItem) {
    return Container(
      height: width / aspectRatio / 3,
      color: editorChoiceTitleBackgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 5.0),
          child: RichText(
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            text: TextSpan(
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.0,
              ),
              text: storyListItem.name,
            ),
          ),
        ),
      ),
    );
  }
}
