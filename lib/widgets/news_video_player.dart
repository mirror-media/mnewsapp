import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class NewsVideoPlayer extends StatefulWidget {
  const NewsVideoPlayer({required this.videoUrl});

  final String videoUrl;

  @override
  State<NewsVideoPlayer> createState() => _NewsVideoPlayerState();
}

class _NewsVideoPlayerState extends State<NewsVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4');
    _controller.initialize()..then((value) {

      _controller.play();
    });

  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Text("error");
  }
}
