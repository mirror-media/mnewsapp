import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tv/baseConfig.dart';
import 'package:tv/blocs/live/liveCubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/widgets/story/youtubeViewer.dart';

class LiveWidget extends StatefulWidget {
  final bool needTitle;
  LiveWidget({this.needTitle = true});
  @override
  _LiveWidgetState createState() => _LiveWidgetState();
}

class _LiveWidgetState extends State<LiveWidget> {
  late bool _needTitle;
  @override
  void initState() {
    _loadLiveId();
    _needTitle = widget.needTitle;
    super.initState();
  }

  _loadLiveId() {
    context.read<LiveCubit>().fetchLiveId(baseConfig!.mNewsLivePostId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveCubit, LiveState>(
      builder: (BuildContext context, LiveState state) {
        if (state is LiveIdLoaded) {
          return Column(
            children: [
              _needTitle
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                      child: _buildLiveTitle('鏡電視 Live'),
                    )
                  : Container(),
              YoutubeViewer(
                state.liveId,
                autoPlay: true,
                isLive: true,
                mute: true,
              ),
            ],
          );
        }
        return Container();
      },
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
}
