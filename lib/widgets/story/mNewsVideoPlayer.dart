import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MNewsVideoPlayer extends StatefulWidget {
  /// The baseUrl of the video
  final String videourl;

  /// Play the video as soon as it's displayed
  final bool autoPlay;

  /// Start video at a certain position
  final Duration? startAt;

  /// Whether or not the video should loop
  final bool looping;

  /// The Aspect Ratio of the Video. Important to get the correct size of the
  /// video!
  ///
  /// Will fallback to fitting within the space allowed.
  final double aspectRatio;

  /// Whether or not the video muted
  final bool muted;

  MNewsVideoPlayer({
    Key? key,
    required this.videourl,
    required this.aspectRatio,
    this.autoPlay = false,
    this.startAt,
    this.muted = false,
    this.looping = false,
  }) : super(key: key);

  @override
  _MNewsVideoPlayerState createState() => _MNewsVideoPlayerState();
}

class _MNewsVideoPlayerState extends State<MNewsVideoPlayer>
    with AutomaticKeepAliveClientMixin {
  late BetterPlayerController _betterPlayerController;
  bool isInitialized = false;
  bool isError = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _configVideoPlayer();
    super.initState();
  }

  Future<void> _configVideoPlayer() async {
    try {
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.videourl,
      );
      _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: widget.autoPlay,
          aspectRatio: widget.aspectRatio,
          startAt: widget.startAt,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableAudioTracks: false,
          ),
          looping: widget.looping,
          autoDetectFullscreenAspectRatio: true,
          autoDetectFullscreenDeviceOrientation: true,
          showPlaceholderUntilPlay: true,
          placeholder: Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          translations: [
            BetterPlayerTranslations(
              languageCode: "zh",
              generalDefaultError: "無法播放影片",
              generalNone: "無",
              generalDefault: "預設",
              generalRetry: "重試",
              playlistLoadingNextVideo: "正在載入下一部影片",
              controlsLive: "直播",
              controlsNextVideoIn: "下一部影片",
              overflowMenuPlaybackSpeed: "播放速度",
              overflowMenuSubtitles: "字幕",
              overflowMenuQuality: "畫質",
              overflowMenuAudioTracks: "音訊",
              qualityAuto: "自動",
            ),
          ],
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
        ),
        betterPlayerDataSource: betterPlayerDataSource,
      );
      if (widget.muted) _betterPlayerController.setVolume(0.0);
      setState(() {
        isInitialized = true;
      });
    } catch (e) {
      print('Video player error: $e');
      setState(() {
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: BetterPlayer(
          controller: _betterPlayerController,
        ),
      );
    } else if (isError) {
      return Container();
    }
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }
}
