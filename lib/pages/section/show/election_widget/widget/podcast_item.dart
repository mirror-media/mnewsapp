import 'package:flutter/material.dart';
import 'package:tv/data/value/string_default.dart';
import 'package:tv/models/podcast_info/podcast_info.dart';

class PodcastItem extends StatelessWidget {
  const PodcastItem({required this.podcastInfo, required this.isPlay});

  final PodcastInfo podcastInfo;
  final bool isPlay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            podcastInfo.timeFormat ?? StringDefault.nullString,
            style: TextStyle(
                color: Color(0xFF4A4A4A),
                fontSize: 14,
                fontWeight: FontWeight.w400),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          podcastInfo.title ?? StringDefault.nullString,
          style: isPlay
              ? TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF004DBC))
              : TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF0D1821)),
        ),
        const SizedBox(height: 4),
        InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              isPlay
                  ? Image.asset(
                      'assets/image/play_icon.png',
                      width: 24,
                      height: 24,
                    )
                  : Image.asset(
                      'assets/image/non_play_icon.png',
                      width: 24,
                      height: 24,
                    ),
              const SizedBox(width: 15),
              SizedBox(
                  width: 63,
                  height: 24,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      podcastInfo.duration ?? StringDefault.nullString,
                      style: TextStyle(
                          color: Color(0xFF004EBC),
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  )),
              const SizedBox(width: 10),
            ],
          ),
        )
      ],
    );
  }
}
