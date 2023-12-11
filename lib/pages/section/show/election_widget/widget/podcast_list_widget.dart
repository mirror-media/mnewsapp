import 'package:flutter/material.dart';
import 'package:tv/models/podcast_info/podcast_info.dart';
import 'package:tv/pages/section/show/election_widget/widget/podcast_item.dart';

class PodcastListWidget extends StatelessWidget {
  const PodcastListWidget(
      {required this.podcastInfoList,
      required this.displayCount,
      required this.selectedPodcastInfo,
      required this.itemClickEvent});

  final List<PodcastInfo> podcastInfoList;
  final int displayCount;
  final PodcastInfo? selectedPodcastInfo;
  final Function(PodcastInfo) itemClickEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Text(
              'podcasts',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 24,
                  color: Color(0xFF014DB8)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 120 * displayCount.toDouble(),
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => itemClickEvent(podcastInfoList[index]),
                  child: PodcastItem(
                    podcastInfo: podcastInfoList[index],
                    isPlay: podcastInfoList[index] == selectedPodcastInfo,
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  color: Colors.black,
                );
              },
              itemCount: displayCount),
        ),
      ],
    );
  }
}
