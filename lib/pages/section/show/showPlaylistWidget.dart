import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tv/blocs/youtubePlaylist/bloc.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/models/showIntro.dart';
import 'package:tv/models/youtubePlaylistInfo.dart';
import 'package:tv/pages/section/show/showPlaylistTabContent.dart';
import 'package:tv/services/youtubePlaylistService.dart';

class ShowPlaylistWidget extends StatefulWidget {
  final ShowIntro showIntro;
  final ScrollController listviewController;
  ShowPlaylistWidget({
    required this.showIntro,
    required this.listviewController,
  });

  @override
  _ShowPlaylistWidgetState createState() => _ShowPlaylistWidgetState();
}

class _ShowPlaylistWidgetState extends State<ShowPlaylistWidget> {
  int _segmentedControlGroupValue = 0;
  Map<int, Widget> _tabs = Map();
  List<Widget> _tabWidgets = List.empty(growable: true);

  @override
  void initState() {
    if (widget.showIntro.playList01 != null &&
        widget.showIntro.playList02 != null) {
      _initializeTabs(widget.showIntro);
    }
    super.initState();
  }

  _initializeTabs(ShowIntro showIntro) {
    _segmentedControlGroupValue = 0;
    _tabs = <int, Widget>{
      0: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 12.0),
        child: Obx(
          () => Text(
            showIntro.playList01!.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
            textScaleFactor:
                Get.find<TextScaleFactorController>().textScaleFactor.value,
          ),
        ),
      ),
      1: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 12.0),
        child: Obx(
          () => Text(
            showIntro.playList02!.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
            textScaleFactor:
                Get.find<TextScaleFactorController>().textScaleFactor.value,
          ),
        ),
      ),
    };
    _tabWidgets = [
      _buildTabWidget(showIntro.playList01!),
      _buildTabWidget(showIntro.playList02!),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    // do not render anything
    if (widget.showIntro.playList01 == null) {
      return Container();
    }
    // just render play list 01
    if (widget.showIntro.playList02 == null) {
      return _buildTabWidget(widget.showIntro.playList01!);
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
              onValueChanged: (int i) {
                setState(() {
                  _segmentedControlGroupValue = i;
                });
              }),
        ),
        SizedBox(height: 24),
        _tabWidgets[_segmentedControlGroupValue],
      ],
    );
  }

  Widget _buildTabWidget(YoutubePlaylistInfo youtubePlaylistInfo) {
    return BlocProvider(
      create: (context) =>
          YoutubePlaylistBloc(youtubePlaylistRepos: YoutubePlaylistServices()),
      child: ShowPlaylistTabContent(
        youtubePlaylistInfo: youtubePlaylistInfo,
        listviewController: widget.listviewController,
      ),
    );
  }
}
