import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tv/helpers/routeGenerator.dart';
import 'package:tv/models/storyListItem.dart';

class NewsStoryFirstItem extends StatelessWidget {
  final StoryListItem storyListItem;
  NewsStoryFirstItem({required this.storyListItem});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return InkWell(
        child: Column(
          children: [
            CachedNetworkImage(
              height: width / 16 * 9,
              width: width,
              imageUrl: storyListItem.photoUrl,
              placeholder: (context, url) => Container(
                height: width / 16 * 9,
                width: width,
                color: Colors.grey,
              ),
              errorWidget: (context, url, error) => Container(
                height: width / 16 * 9,
                width: width,
                color: Colors.grey,
                child: Icon(Icons.error),
              ),
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
              child: RichText(
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    height: 1.5,
                  ),
                  text: storyListItem.name,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          RouteGenerator.navigateToStory(context, storyListItem.slug);
        });
  }
}
