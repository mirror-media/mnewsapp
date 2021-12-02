import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/helpers/routeGenerator.dart';
import 'package:tv/models/storyListItem.dart';

class NewsStoryListItem extends StatelessWidget {
  final StoryListItem storyListItem;
  final String categorySlug;
  NewsStoryListItem({
    required this.storyListItem,
    this.categorySlug = 'latest',
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double imageSize = 33.3 * (width - 32) / 100;
    if (imageSize > 150) imageSize = 150;

    return InkWell(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                height: imageSize,
                width: imageSize,
                imageUrl: storyListItem.photoUrl,
                placeholder: (context, url) => Container(
                  height: imageSize,
                  width: imageSize,
                  color: Colors.grey,
                ),
                errorWidget: (context, url, error) => Container(
                  height: imageSize,
                  width: imageSize,
                  color: Colors.grey,
                  child: Icon(Icons.error),
                ),
                fit: BoxFit.cover,
              ),
              SizedBox(
                width: 16,
              ),
              Expanded(
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4,
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
        ),
        onTap: () {
          AnalyticsHelper.logClick(
            slug: storyListItem.slug,
            title: storyListItem.name,
            location:
                categorySlug == 'latest' ? 'HomePage_最新列表' : 'CategoryPage_列表',
          );
          RouteGenerator.navigateToStory(context, storyListItem.slug);
        });
  }
}
