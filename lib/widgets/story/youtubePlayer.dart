import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tv/widgets/story/youtubeViewer.dart';
import 'package:youtube_plyr_iframe/youtube_plyr_iframe.dart';

class YoutubePlayer extends StatefulWidget {
  final String videoID;
  final bool isLive;
  YoutubePlayer(
    this.videoID, {
    this.isLive = false,
  });

  @override
  _YoutubePlayerState createState() => _YoutubePlayerState();
}

class _YoutubePlayerState extends State<YoutubePlayer> {
  bool _isPlaying = false;
  String _youtubeThumbnail = '';

  @override
  void initState() {
    _youtubeThumbnail = YoutubePlayerController.getThumbnail(
        videoId: widget.videoID,
        // todo: get thumbnail quality from list
        quality: ThumbnailQuality.max,
        webp: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double imageWidth = MediaQuery.of(context).size.width;
    double imageHeight = imageWidth / 16 * 9;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _isPlaying = !_isPlaying;
          });
        },
        child: !_isPlaying
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Stack(
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
                    ],
                  ),
                  Icon(
                    Icons.play_circle_filled,
                    color: Colors.white,
                    size: 55.0,
                  ),
                ],
              )
            : YoutubeViewer(
                widget.videoID,
                autoPlay: true,
                isLive: widget.isLive,
              ),
      ),
    );
  }
}
