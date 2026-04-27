import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tv/bindings/live_widget_binding.dart';
import 'package:tv/controller/live_widget_controller.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/widgets/youtube/youtubePlayer.dart';

class LiveWidget extends StatefulWidget {
  final bool needBuildLiveTitle;
  final String liveTitle;
  final IconData icon;
  final bool showIcon;
  final String livePostId;
  LiveWidget({
    this.needBuildLiveTitle = true,
    this.liveTitle = '鏡新聞 Live',
    this.icon = FontAwesomeIcons.podcast,
    this.showIcon = true,
    required this.livePostId,
  });
  @override
  _LiveWidgetState createState() => _LiveWidgetState();
}

class _LiveWidgetState extends State<LiveWidget> {
  late bool _needBuildLiveTitle;
  late bool _showIcon;

  @override
  void initState() {
    _needBuildLiveTitle = widget.needBuildLiveTitle;
    _showIcon = widget.showIcon;
    LiveWidgetBinding(widget.livePostId).dependencies();
    super.initState();
  }

  @override
  void dispose() {
    if (Get.isRegistered<LiveWidgetController>(tag: widget.livePostId)) {
      Get.delete<LiveWidgetController>(tag: widget.livePostId);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LiveWidgetController>(tag: widget.livePostId);
    return Obx(() {
      final liveId = controller.liveId.value;
      if (liveId == null || liveId.isEmpty) {
        return Container();
      }

      return Column(
        children: [
          _needBuildLiveTitle
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: _buildLiveTitle(widget.liveTitle, widget.icon),
                )
              : Container(),
          YoutubePlayer(
            liveId,
            autoPlay: true,
            mute: true,
          ),
        ],
      );
    });
  }

  Widget _buildLiveTitle(String title, IconData icon) {
    final TextScaleFactorController textScaleFactorController = Get.find();
    return Row(
      children: [
        Obx(
          () => Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            textScaleFactor: textScaleFactorController.textScaleFactor.value,
          ),
        ),
        SizedBox(width: 8.0),
        _showIcon
            ? FaIcon(
                icon,
                size: 18,
                color: Colors.red,
              )
            : Container(),
      ],
    );
  }
}
