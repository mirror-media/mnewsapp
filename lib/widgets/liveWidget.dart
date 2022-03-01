import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tv/blocs/live/liveCubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/widgets/youtubeLiveViewer.dart';

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
    _loadLiveId();
    _needBuildLiveTitle = widget.needBuildLiveTitle;
    _showIcon = widget.showIcon;
    super.initState();
  }

  _loadLiveId() {
    context.read<LiveCubit>().fetchLiveId(widget.livePostId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveCubit, LiveState>(
      builder: (BuildContext context, LiveState state) {
        if (state is LiveIdLoaded) {
          return Column(
            children: [
              _needBuildLiveTitle
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                      child: _buildLiveTitle(widget.liveTitle, widget.icon),
                    )
                  : Container(),
              YoutubeLiveViewer(
                state.liveId,
                autoPlay: true,
                mute: true,
              ),
            ],
          );
        }
        return Container();
      },
    );
  }

  Widget _buildLiveTitle(String title, IconData icon) {
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
