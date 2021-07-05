import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_plyr_iframe/youtube_plyr_iframe.dart';

class YoutubeViewer extends StatefulWidget {
  final String videoID;
  final bool autoPlay;
  final bool isLive;
  YoutubeViewer(
    this.videoID,
    {
      this.autoPlay = false,
      this.isLive = false,
    }
  );

  @override
  _YoutubeViewerState createState() => _YoutubeViewerState();
}

class _YoutubeViewerState extends State<YoutubeViewer> with AutomaticKeepAliveClientMixin {
  // ignore: close_sinks
  late YoutubePlayerController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoID,
      params: YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        // iOS can not trigger full screen when desktopMode is true
        desktopMode: Platform.isAndroid, // false for platform design
        autoPlay: widget.autoPlay,
        enableCaption: true,
        showVideoAnnotations: false,
        enableJavaScript: true,
        privacyEnhanced: true,
        playsInline: true, // iOS only
      ),
    )..listen((value) {
        if (value.isReady && !value.hasPlayed) {
          _controller
            ..hidePauseOverlay()
            ..hideTopMenu();
          if(widget.autoPlay) {
            _controller.play();
          }
        }
      });

    // Uncomment below for device orientation
    _controller.onEnterFullscreen = () {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      log('Entered Fullscreen');
    };
    _controller.onExitFullscreen = () {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      Future.delayed(const Duration(seconds: 1), () {
        _controller.play();
      });
      Future.delayed(const Duration(seconds: 5), () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      });
      log('Exited Fullscreen');
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final player = YoutubePlayerIFrame();
    if(widget.isLive && Platform.isAndroid) {
      return Stack(
        children: [
          YoutubePlayerControllerProvider(
            controller: _controller,
            child: player,
          ),
          Positioned(
            right: 8.0,
            top: 8.0,
            child: Text(
              'Live',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      );
    }

    return YoutubePlayerControllerProvider(
      controller: _controller,
      child: player,
    );
  }
}