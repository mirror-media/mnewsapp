import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeStreamWidget extends StatelessWidget {
  final String? youtubeUrl;
  final String? youtubeId;
  final bool autoPlay;
  final bool isLive;

  const YoutubeStreamWidget({
    Key? key,
    this.youtubeUrl,
    this.youtubeId,
    this.autoPlay = false,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    final videoId = YoutubePlayer.convertUrlToId(youtubeUrl ?? '');
    YoutubePlayerController controller = YoutubePlayerController(
      initialVideoId: youtubeId ?? videoId ?? '',
      flags: YoutubePlayerFlags(
        isLive: isLive,
        autoPlay: autoPlay,
      ),
    );

    return YoutubePlayer(
      controller: controller,
      showVideoProgressIndicator: false,
      bottomActions: const [],
    );
  }
}
