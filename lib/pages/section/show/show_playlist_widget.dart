import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tv/controller/text_scale_factor_controller.dart';
import 'package:tv/models/showIntro.dart';
import 'package:tv/models/youtubePlaylistInfo.dart';
import 'package:tv/pages/section/show/show_playlist_tab_content.dart';

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
    // ===== 選單排查 log =====
    print('[選單排查] ShowPlaylistWidget.initState '
        'A.id=${widget.showIntro.playList01?.youtubePlayListId} '
        'B.id=${widget.showIntro.playList02?.youtubePlayListId}');
    if (widget.showIntro.playList01 != null &&
        widget.showIntro.playList02 != null) {
      initializeTabs(widget.showIntro);
    }
  }

  void initializeTabs(ShowIntro showIntro) {
    // ===== 選單排查 log =====
    print('[選單排查] initializeTabs '
        'A(name=${showIntro.playList01!.name}, id=${showIntro.playList01!.youtubePlayListId}) | '
        'B(name=${showIntro.playList02!.name}, id=${showIntro.playList02!.youtubePlayListId})');
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
              // ===== 選單排查 log:這就是「點擊選單」事件 =====
              print('[選單排查] 點擊 segmented tab -> index=$i '
                  '(0=選單A / 1=選單B)');
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
    // ===== 選單排查 log =====
    print('[選單排查] buildTabWidget 建立 tab widget tag=$controllerTag');
    return ShowPlaylistTabContent(
      // key 讓 Flutter 切換選單時把舊分頁的 State dispose、建立新的 State;
      // 少了 key,兩個分頁同為 ShowPlaylistTabContent 會共用同一個 State,
      // initState 不會重跑 -> 點選單 B 時 binding/controller 不會重建,清單不更新。
      key: ValueKey(controllerTag),
      controllerTag: controllerTag,
      youtubePlaylistInfo: youtubePlaylistInfo,
      listviewController: widget.listviewController,
    );
  }
}
