import 'package:flutter/material.dart';
import 'package:tv/helpers/dataConstants.dart';

class StoryPage extends StatefulWidget {
  final String slug;
  StoryPage({
    @required this.slug,
  });

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: Center(child: Text(widget.slug)),
    );
  }

  Widget _buildBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: appBarColor,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.text_fields),
          tooltip: 'Search',
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.share),
          tooltip: 'Share',
          onPressed: () {},
        ),
      ],
    );
  }
}