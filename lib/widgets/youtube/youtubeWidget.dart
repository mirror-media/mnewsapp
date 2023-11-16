import 'package:flutter/material.dart';
import 'package:tv/widgets/youtube_stream_widget.dart';

class YoutubeWidget extends StatefulWidget {
  final String youtubeId;
  final String? description;
  final double textSize;

  YoutubeWidget(
      {required this.youtubeId, this.description, this.textSize = 20});

  @override
  _YoutubeWidgetState createState() => _YoutubeWidgetState();
}

class _YoutubeWidgetState extends State<YoutubeWidget> {
  late double textSize;

  @override
  void initState() {
    super.initState();
    textSize = widget.textSize;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        YoutubeStreamWidget(youtubeId: widget.youtubeId.replaceAll('/', '')),
        if (widget.description != null && widget.description != '')
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              widget.description!,
              style: TextStyle(fontSize: textSize - 4, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
