import 'package:flutter/material.dart';
import 'package:tv/widgets/story/youtubePlayer.dart';

class YoutubeWidget extends StatefulWidget {
  final String youtubeId;
  final String? description;
  YoutubeWidget({
    required this.youtubeId,
    this.description,
  });

  @override
  _YoutubeWidgetState createState() => _YoutubeWidgetState();
}

class _YoutubeWidgetState extends State<YoutubeWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        YoutubePlayer(widget.youtubeId),
        if (widget.description != null && widget.description != '')
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              widget.description!,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
