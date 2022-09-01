import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubePlayer extends StatefulWidget {
  final String videoID;
  final bool autoPlay;
  final bool mute;
  YoutubePlayer(
    this.videoID, {
    this.autoPlay = false,
    this.mute = false,
  });

  @override
  _YoutubePlayerState createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<YoutubePlayer>
    with AutomaticKeepAliveClientMixin {
  String _youtubeThumbnail = '';
  late double imageWidth;
  late double imageHeight;
  late BetterPlayerController _betterPlayerController;
  bool isInitialized = false;
  bool isError = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _youtubeThumbnail = ThumbnailSet(widget.videoID).maxResUrl;
    _configVideoPlayer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    imageWidth = MediaQuery.of(context).size.width;
    imageHeight = imageWidth / 16 * 9;

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
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        CachedNetworkImage(
          width: imageWidth,
          height: imageHeight,
          imageUrl: _youtubeThumbnail,
          placeholder: (context, url) => Container(
            width: imageWidth,
            height: imageHeight,
            color: Colors.black,
          ),
          errorWidget: (context, url, error) => Container(
            width: imageWidth,
            height: imageHeight,
            color: Colors.black,
          ),
          fit: BoxFit.fitWidth,
        ),
        Icon(
          Icons.play_circle_filled,
          color: Colors.white,
          size: 55.0,
        ),
      ],
    );
  }

  Future<void> _configVideoPlayer() async {
    final yt = YoutubeExplode();
    try {
      final video = await yt.videos.get(widget.videoID);
      bool isLive = video.isLive;
      Map<String, String>? resolutions;
      String defaultVideoUrl = '';

      //fetch video stream url
      final manifest =
          await yt.videos.streamsClient.getManifest(widget.videoID);
      final streamInfoList = manifest.muxed.sortByVideoQuality();

      //if streamInfoList empty, means that the video may is live
      if (streamInfoList.isEmpty) {
        defaultVideoUrl = await yt.videos.streamsClient
            .getHttpLiveStreamUrl(VideoId(widget.videoID));
      } else {
        resolutions = {};
        for (var streamInfo in streamInfoList) {
          resolutions.putIfAbsent(
              streamInfo.qualityLabel, () => streamInfo.url.toString());
        }
        defaultVideoUrl = manifest.muxed.withHighestBitrate().url.toString();
      }

      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        defaultVideoUrl,
        liveStream: isLive,
        resolutions: resolutions,
      );
      _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: widget.autoPlay,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableAudioTracks: false,
          ),
          autoDetectFullscreenAspectRatio: true,
          autoDetectFullscreenDeviceOrientation: true,
          fit: BoxFit.contain,
          showPlaceholderUntilPlay: true,
          placeholder: CachedNetworkImage(
            width: imageWidth,
            height: imageHeight,
            imageUrl: _youtubeThumbnail,
            placeholder: (context, url) => Container(
              width: imageWidth,
              height: imageHeight,
              color: Colors.black,
            ),
            errorWidget: (context, url, error) => Container(
              width: imageWidth,
              height: imageHeight,
              color: Colors.black,
            ),
            fit: BoxFit.fitWidth,
          ),
          translations: [
            BetterPlayerTranslations(
              languageCode: "zh",
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
            ),
          ],
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ],
        ),
        betterPlayerDataSource: betterPlayerDataSource,
      );
      if (widget.mute) _betterPlayerController.setVolume(0.0);
      setState(() {
        isInitialized = true;
      });
    } catch (e) {
      print('Youtube player error: $e');
      setState(() {
        isError = true;
      });
    }
    yt.close();
  }
}
