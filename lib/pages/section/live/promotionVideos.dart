import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/promotionVideo/bloc.dart';
import 'package:tv/blocs/promotionVideo/events.dart';
import 'package:tv/blocs/promotionVideo/states.dart';
import 'package:tv/models/youtubePlaylistItemList.dart';
import 'package:tv/widgets/story/youtubeViewer.dart';
import 'package:youtube_plyr_iframe/youtube_plyr_iframe.dart';

class PromotionVideos extends StatefulWidget {
  @override
  _PromotionVideosState createState() => _PromotionVideosState();
}

class _PromotionVideosState extends State<PromotionVideos> {
  int _selectedIndex = -1;

  @override
  void initState() {
    _fetchAllPromotionVideos();
    super.initState();
  }

  _fetchAllPromotionVideos() async {
    context.read<PromotionVideoBloc>().add(FetchAllPromotionVideos());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PromotionVideoBloc, PromotionVideoState>(
        builder: (BuildContext context, PromotionVideoState state) {
      if (state is PromotionVideoError) {
        final error = state.error;
        print('PromotionVideosError: ${error.message}');
        return Container();
      }
      if (state is PromotionVideoLoaded) {
        YoutubePlaylistItemList youtubePlaylistItemList =
            state.youtubePlaylistItemList;

        if (youtubePlaylistItemList.length == 0) {
          return Container();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: _buildTitle('發燒單元'),
            ),
            ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) =>
                    SizedBox(height: 16.0),
                itemCount: youtubePlaylistItemList.length,
                itemBuilder: (context, index) {
                  return ytPlayer(
                      youtubePlaylistItemList[index].youtubeVideoId, index);
                }),
          ],
        );
      }

      // state is Init, loading, or other
      return Container();
    });
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget ytPlayer(String videoID, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: !(_selectedIndex == index)
            ? Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (kIsWeb && constraints.maxWidth > 800) {
                            return Container(
                              color: Colors.transparent,
                              padding: EdgeInsets.all(5),
                              width: MediaQuery.of(context).size.width / 2,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  YoutubePlayerController.getThumbnail(
                                      videoId: videoID,
                                      // todo: get thumbnail quality from list
                                      quality: ThumbnailQuality.max,
                                      webp: false),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            );
                          } else {
                            return Container(
                              color: Colors.transparent,
                              width: MediaQuery.of(context).size.width * 2,
                              child: Image.network(
                                YoutubePlayerController.getThumbnail(
                                    videoId: videoID,
                                    // todo: get thumbnail quality from list
                                    quality: ThumbnailQuality.max,
                                    webp: false),
                                fit: BoxFit.fill,
                              ),
                            );
                          }
                        },
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
                videoID,
                autoPlay: true,
                isLive: true,
              ),
      ),
    );
  }
}
