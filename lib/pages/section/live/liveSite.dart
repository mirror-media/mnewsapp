import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tv/widgets/story/youtubeViewer.dart';
import 'package:youtube_plyr_iframe/youtube_plyr_iframe.dart';
import 'package:tv/blocs/youtubePlaylist/bloc.dart';
import 'package:tv/blocs/youtubePlaylist/events.dart';
import 'package:tv/blocs/youtubePlaylist/states.dart';
import 'package:tv/models/youtubePlaylistItemList.dart';
import 'package:tv/helpers/dataConstants.dart';

class LiveSite extends StatefulWidget {
  @override
  _LiveSiteState createState() => _LiveSiteState();
}

class _LiveSiteState extends State<LiveSite> {
  int _selectedIndex = -1;

  @override
  void initState() {
    _fetchSnippetByPlaylistId(mNewsLiveSiteYoutubePlayListId);
    super.initState();
  }

  _fetchSnippetByPlaylistId(String id) async {
    context.read<YoutubePlaylistBloc>().add(FetchSnippetByPlaylistId(id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubePlaylistBloc, YoutubePlaylistState>(
      builder: (BuildContext context, YoutubePlaylistState state) {
        if (state is YoutubePlaylistError) {
          final error = state.error;
          print('LiveSite YoutubePlaylistError: ${error.message}');
          return Container();
        }
        if (state is YoutubePlaylistLoaded) {
          YoutubePlaylistItemList youtubePlaylistItemList = state.youtubePlaylistItemList;
          
          if(youtubePlaylistItemList.length == 0) {
            return Container();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: _buildLiveTitle('直播現場'),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) => SizedBox(height: 16.0),
                itemCount: youtubePlaylistItemList.length,
                itemBuilder: (context, index) {
                  return ytPlayer(youtubePlaylistItemList[index].youtubeVideoId, index);
                }
              ),
            ],
          );
        }

        // state is Init, loading, or other 
        return Container();
      }
    );
  }
  
  Widget _buildLiveTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 8.0),
        FaIcon(
          FontAwesomeIcons.podcast,
          size: 18,
          color: Colors.red,
        ),
      ],
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
        child: ! (_selectedIndex == index)
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