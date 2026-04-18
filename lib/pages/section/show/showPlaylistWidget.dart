import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/models/showIntro.dart';
import 'package:tv/models/youtubePlaylistInfo.dart';
import 'package:tv/pages/section/show/showPlaylistTabContent.dart';

class ShowPlaylistWidget extends StatefulWidget {
  const ShowPlaylistWidget({
    super.key,
    required this.showIntro,
    required this.listviewController,
  });

  final ShowIntro showIntro;
  final ScrollController listviewController;

  @override
  State<ShowPlaylistWidget> createState() => _ShowPlaylistWidgetState();
}

class _ShowPlaylistWidgetState extends State<ShowPlaylistWidget> {
  int segmentedControlGroupValue = 0;
  Map<int, Widget> tabs = {};
  List<Widget> tabWidgets = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    if (widget.showIntro.playList01 != null &&
        widget.showIntro.playList02 != null) {
      initializeTabs(widget.showIntro);
    }
  }

  void initializeTabs(ShowIntro showIntro) {
    segmentedControlGroupValue = 0;
    tabs = <int, Widget>{
      0: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 12.0),
        child: Obx(
          () => Text(
            showIntro.playList01!.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
            textScaleFactor:
                Get.find<TextScaleFactorController>().textScaleFactor.value,
          ),
        ),
      ),
    };
    tabWidgets = [
      buildTabWidget(showIntro.playList01!, 'playlist_01'),
      buildTabWidget(showIntro.playList02!, 'playlist_02'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (widget.showIntro.playList01 == null) {
      return Container();
    }
    if (widget.showIntro.playList02 == null) {
      return buildTabWidget(widget.showIntro.playList01!, 'playlist_single');
    }

    return Center(child: buildTabs(width));
  }

  Widget buildTabs(double width) {
    return Column(
      children: [
        SizedBox(
          width: width,
          child: CupertinoSegmentedControl(
            padding: const EdgeInsets.all(0),
            borderColor: const Color(0xff004DBC),
            selectedColor: const Color(0xff004DBC),
            groupValue: segmentedControlGroupValue,
            children: tabs,
            onValueChanged: (int i) {
              setState(() {
                segmentedControlGroupValue = i;
              });
            },
          ),
        ),
        const SizedBox(height: 24),
        tabWidgets[segmentedControlGroupValue],
      ],
    );
  }

  Widget buildTabWidget(
    YoutubePlaylistInfo youtubePlaylistInfo,
    String suffix,
  ) {
    final controllerTag = '${youtubePlaylistInfo.youtubePlayListId}_$suffix';
    return ShowPlaylistTabContent(
      controllerTag: controllerTag,
      youtubePlaylistInfo: youtubePlaylistInfo,
      listviewController: widget.listviewController,
    );
  }
}
