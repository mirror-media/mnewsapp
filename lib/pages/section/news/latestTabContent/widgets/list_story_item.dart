import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/data/value/string_default.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/pages/storyPage.dart';

class ListStoryItem extends StatelessWidget {
  const ListStoryItem({super.key, required this.item});

  final StoryListItem item;

  /// 移除Category 先用註解的 避免後續要再加回來
  Widget categoryRender() {
    if (item.isSales == true) {
      return Container(
        width: 46,
        height: 28,
        decoration: const BoxDecoration(
          color: Color(0xFFFFCC00),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(2)),
        ),
        child: const Center(
          child: Text(
            '特企',
            style: TextStyle(
              color: Color(0xFF003366),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              fontFamily: 'PingFang TC',
            ),
          ),
        ),
      );
    } else {
      if (item.displayCategory != null && item.displayCategory!.isNotEmpty) {
        return Container(
          width: 46,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFF003366),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(2)),
          ),
          child: Center(
            child: Text(
              item.displayCategory!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                fontFamily: 'PingFang TC',
              ),
            ),
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (item.slug == null || item.slug!.isEmpty) return;
        Get.to(() => StoryPage(slug: item.slug!));
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(2.0),
                child: Image.network(
                  item.photoUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 90,
                      height: 90,
                      color: const Color(0xFFEAEAEA),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                        size: 28,
                      ),
                    );
                  },
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
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 90,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.name ?? StringDefault.nullString,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF151515),
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}