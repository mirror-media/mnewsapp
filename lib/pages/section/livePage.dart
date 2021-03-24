import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/widgets/story/youtubeViewer.dart';

class LivePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: _buildLiveTitle('鏡電視 Live'),
            ),
            
            YoutubeViewer(
              mNewsLiveYoutubeId,
              autoPlay: true,
              isLive: true,
            ),
          ],
        ),
      ],
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