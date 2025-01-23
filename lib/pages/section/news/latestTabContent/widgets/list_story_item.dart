import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/data/value/string_default.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/pages/storyPage.dart';

class ListStoryItem extends StatelessWidget {
  const ListStoryItem({required this.item});

  final StoryListItem item;

  /// 移除Category 先用註解的 避免後續要再加回來
  Widget categoryRender() {
    if (item.isSales!) {
      return Container(
        width: 46,
        height: 28,
        decoration: BoxDecoration(
          color: Color(0xFFFFCC00),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(2)),
        ),
        child: Center(
          child: Text('特企',
              style: TextStyle(
                  color: Color(0xFF003366),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'PingFang TC')),
        ),
      );
    } else {
      if (item.displayCategory != null) {
        return Container(
          width: 46,
          height: 28,
          decoration: BoxDecoration(
            color: Color(0xFF003366),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(2)),
          ),
          child: Center(
              child: Text(
            item.displayCategory!,
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                fontFamily: 'PingFang TC'),
          )),
        );
      }
    }
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (item.slug == null) return;
        Get.to(() => StoryPage(
              slug: item.slug!,
            ));
      },
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(2.0),
                child: Image.network(
                  item.photoUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.fitHeight,
                ),
              ),
              if (item.style == 'videoNews')
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2.0),
                    child: Image.asset(
                      'assets/image/article_video_news_icon.png',
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: SizedBox(
              child: Text(
                item.name ?? StringDefault.nullString,
                style: TextStyle(
                    color: Color(0xFF151515),
                    fontSize: 20,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
