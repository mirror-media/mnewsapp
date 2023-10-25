import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeStreamWidget extends StatelessWidget {
  final String? youtubeUrl;
  final String? youtubeId;

  const YoutubeStreamWidget({Key? key, this.youtubeUrl, this.youtubeId});

  @override
  Widget build(BuildContext context) {
    final videoId = YoutubePlayer.convertUrlToId(youtubeUrl ?? '');
    YoutubePlayerController controller = YoutubePlayerController(
        initialVideoId: youtubeId ?? videoId ?? '',
        flags: const YoutubePlayerFlags(isLive: false, autoPlay: false));

    return YoutubePlayer(
      controller: controller,
      showVideoProgressIndicator: false,
      bottomActions: const [],
    );
  }
}
