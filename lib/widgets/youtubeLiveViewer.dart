import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeLiveViewer extends StatefulWidget {
  final String videoID;
  final bool autoPlay;
  final bool mute;
  YoutubeLiveViewer(
    this.videoID, {
    this.autoPlay = false,
    this.mute = false,
  });

  @override
  _YoutubeLiveViewerState createState() => _YoutubeLiveViewerState();
}

class _YoutubeLiveViewerState extends State<YoutubeLiveViewer>
    with AutomaticKeepAliveClientMixin {
  // ignore: close_sinks
  late BetterPlayerController _betterPlayerController;
  late Future<bool> _configPlayerFuture;
  var yt = YoutubeExplode();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _configPlayerFuture = _configVideoPlayer();
    super.initState();
  }

  Future<bool> _configVideoPlayer() async {
    try {
      String videoUrl = await yt.videos.streamsClient
          .getHttpLiveStreamUrl(VideoId(widget.videoID));
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        videoUrl,
        liveStream: true,
      );
      _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: widget.autoPlay,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableAudioTracks: false,
            enableOverflowMenu: false,
          ),
          autoDetectFullscreenAspectRatio: true,
          autoDetectFullscreenDeviceOrientation: true,
          fit: BoxFit.contain,
          translations: [
            BetterPlayerTranslations.chinese(),
            BetterPlayerTranslations(
              languageCode: "zh-TW",
              generalDefaultError: "無法播放影片",
              generalNone: "沒有",
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
            )
          ],
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
        ),
        betterPlayerDataSource: betterPlayerDataSource,
      );
      if (widget.mute) _betterPlayerController.setVolume(0.0);
    } catch (e) {
      print('Youtube player error: $e');
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    yt.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<bool>(
      initialData: false,
      future: _configPlayerFuture,
      builder: (context, snapshot) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (snapshot.data == null || !snapshot.data!) {
              return Container(
                width: constraints.maxWidth,
                height: constraints.maxWidth / (16 / 9),
                child: Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              );
            }

            return AspectRatio(
              aspectRatio: 16 / 9,
              child: BetterPlayer(
                controller: _betterPlayerController,
              ),
            );
          },
        );
      },
    );
  }
}
