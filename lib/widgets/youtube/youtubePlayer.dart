import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubePlayer extends StatefulWidget {
  final String videoID;
  final bool autoPlay;
  final bool mute;

  const YoutubePlayer(
      this.videoID, {
        super.key,
        this.autoPlay = false,
        this.mute = false,
      });

  @override
  State<YoutubePlayer> createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<YoutubePlayer>
    with AutomaticKeepAliveClientMixin {
  late String _youtubeThumbnail;
  late double imageWidth;
  late double imageHeight;

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool _isInitialized = false;
  bool _isError = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _youtubeThumbnail = ThumbnailSet(widget.videoID).maxResUrl;
    _initYoutubeVideo();
  }

  @override
  void didUpdateWidget(covariant YoutubePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoID != widget.videoID) {
      _disposeControllers();
      _youtubeThumbnail = ThumbnailSet(widget.videoID).maxResUrl;
      _isInitialized = false;
      _isError = false;
      _initYoutubeVideo();
    }
  }

  Future<void> _initYoutubeVideo() async {
    final yt = YoutubeExplode();

    try {
      final manifest = await yt.videos.streamsClient.getManifest(widget.videoID);
      String videoUrl;

      if (manifest.muxed.isNotEmpty) {
        videoUrl = manifest.muxed.withHighestBitrate().url.toString();
      } else {
        videoUrl = await yt.videos.streamsClient
            .getHttpLiveStreamUrl(VideoId(widget.videoID));
      }

      yt.close();

      final controller =
      VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await controller.initialize();
      await controller.setLooping(false);

      if (widget.mute) {
        await controller.setVolume(0.0);
      }

      final chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: widget.autoPlay,
        showControlsOnInitialize: false,
        allowPlaybackSpeedChanging: true,
        deviceOrientationsOnEnterFullScreen: const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: const [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      );

      if (!mounted) {
        chewieController.dispose();
        await controller.dispose();
        return;
      }

      _videoController = controller;
      _chewieController = chewieController;

      if (widget.autoPlay) {
        await _videoController?.play();
      }

      setState(() {
        _isInitialized = true;
        _isError = false;
      });
    } catch (e) {
      yt.close();
      print('Youtube error: $e');

      if (!mounted) return;

      setState(() {
        _isError = true;
        _isInitialized = false;
      });
    }
  }

  void _disposeControllers() {
    _chewieController?.dispose();
    _chewieController = null;

    _videoController?.dispose();
    _videoController = null;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    imageWidth = MediaQuery.of(context).size.width;
    imageHeight = imageWidth / 16 * 9;

    if (_isError) {
      return Container(
        width: imageWidth,
        height: imageHeight,
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.error, color: Colors.white),
        ),
      );
    }

    if (!_isInitialized || _chewieController == null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          CachedNetworkImage(
            width: imageWidth,
            height: imageHeight,
            imageUrl: _youtubeThumbnail,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: Colors.black),
            errorWidget: (_, __, ___) => Container(color: Colors.black),
          ),
          const CircularProgressIndicator.adaptive(),
        ],
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Chewie(controller: _chewieController!),
    );
  }
}