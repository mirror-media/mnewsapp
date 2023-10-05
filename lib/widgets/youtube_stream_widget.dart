import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeStreamWidget extends StatelessWidget {
  final String? youtubeUrl;

  const YoutubeStreamWidget({Key? key, this.youtubeUrl});

  @override
  Widget build(BuildContext context) {
    String? videoId;
    videoId = YoutubePlayer.convertUrlToId(youtubeUrl ?? '');
    YoutubePlayerController controller = YoutubePlayerController(
        initialVideoId: videoId ?? '',
        flags: const YoutubePlayerFlags(isLive: false, autoPlay: false));

    return YoutubePlayer(
      controller: controller,
      showVideoProgressIndicator: false,
      bottomActions: const [],
    );
  }
}
