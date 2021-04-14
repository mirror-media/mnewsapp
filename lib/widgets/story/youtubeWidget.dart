import 'package:flutter/material.dart';
import 'package:tv/widgets/story/youtubeViewer.dart';

class YoutubeWidget extends StatefulWidget {
  final String youtubeId;
  final String description;
  final double width;
  YoutubeWidget({
    @required this.width,
    @required this.youtubeId,
    this.description,
  });

  @override
  _YoutubeWidgetState createState() => _YoutubeWidgetState();
}

class _YoutubeWidgetState extends State<YoutubeWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        YoutubeViewer(widget.youtubeId),
        if (widget.description != null && widget.description != '')
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              widget.description,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
