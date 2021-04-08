import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/youtubePlaylist/bloc.dart';
import 'package:tv/models/showIntro.dart';
import 'package:tv/models/youtubePlaylistInfo.dart';
import 'package:tv/services/youtubePlaylistService.dart';
import 'package:tv/widgets/showPlaylistTabContent.dart';

class ShowPlaylistWidget extends StatefulWidget {
  final ShowIntro showIntro;
  ShowPlaylistWidget({
    @required this.showIntro,
  });

  @override
  _ShowPlaylistWidgetState createState() => _ShowPlaylistWidgetState();
}

class _ShowPlaylistWidgetState extends State<ShowPlaylistWidget> {
  int _segmentedControlGroupValue = 0;
  Map<int, Widget> _tabs = Map();
  List<Widget> _tabWidgets = List<Widget>();

  @override
  void initState() {
    if(widget.showIntro.playList01.youtubePlayListId != null &&
    widget.showIntro.playList02.youtubePlayListId != null) {
      _initializeTabs(widget.showIntro);
    }
    
    super.initState();
  }

  _initializeTabs(ShowIntro showIntro) {
    _segmentedControlGroupValue = 0;
    _tabs = <int, Widget>{
      0: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 12.0),
          child: Text(
            showIntro.playList01.name,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      1: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 12.0),
          child: Text(
            showIntro.playList02.name,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
    };
    _tabWidgets = [
      _buildTabWidget(showIntro.playList01),
      _buildTabWidget(showIntro.playList02),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    // do not render anything
    if(widget.showIntro.playList01.youtubePlayListId == null) {
      return Container();
    }
    // just render play list 01
    if(widget.showIntro.playList02.youtubePlayListId == null) {
      return _buildTabWidget(widget.showIntro.playList01);
    }

    return Center(child: _buildTabs(width));
  }

  Widget _buildTabs(double width) {

    return Column(
      children: [
        SizedBox(
          width: width,
          child: CupertinoSegmentedControl(
            padding: const EdgeInsets.all(0),
            borderColor: Color(0xff004DBC),
            selectedColor: Color(0xff004DBC),
            groupValue: _segmentedControlGroupValue,
            children: _tabs,
            onValueChanged: (i) {
              setState(() {
                _segmentedControlGroupValue = i;
              });
            }
          ),
        ),
        SizedBox(height: 24),
        _tabWidgets[_segmentedControlGroupValue],
      ],
    );
  }

  Widget _buildTabWidget(YoutubePlaylistInfo youtubePlaylistInfo) {
    return BlocProvider(
      create: (context) => YoutubePlaylistBloc(youtubePlaylistRepos: YoutubePlaylistServices()),
      child: ShowPlaylistTabContent(
        key: UniqueKey(),
        youtubePlaylistInfo: youtubePlaylistInfo
      ),
    );
  }
}