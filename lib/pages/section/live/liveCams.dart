import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tv/blocs/live/liveCubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/widgets/youtubeLiveViewer.dart';

class LiveCams extends StatefulWidget {
  @override
  _LiveCamsState createState() => _LiveCamsState();
}

class _LiveCamsState extends State<LiveCams> {
  @override
  void initState() {
    _fetchAllLiveCams();
    super.initState();
  }

  _fetchAllLiveCams() async {
    context.read<LiveCubit>().fetchLiveIdList("stream");
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveCubit, LiveState>(
      builder: (BuildContext context, LiveState state) {
        if (state is LiveIdListLoaded) {
          if (state.liveIdList.isEmpty) {
            return Container();
          }
          List<Widget> liveCamPlayers = [];
          liveCamPlayers.add(Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                Text(
                  '直播現場',
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
            ),
          ));
          state.liveIdList.forEach((element) {
            liveCamPlayers.add(YoutubeLiveViewer(
              element,
              autoPlay: true,
              mute: true,
            ));
          });
          return ListView.separated(
            itemBuilder: (context, index) {
              return liveCamPlayers[index];
            },
            separatorBuilder: (context, index) {
              return SizedBox(
                height: 24,
              );
            },
            itemCount: liveCamPlayers.length,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
          );
        }
        return Container();
      },
    );
  }
}
