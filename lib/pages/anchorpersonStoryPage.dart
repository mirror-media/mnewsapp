import 'package:flutter/material.dart';
import 'package:tv/helpers/dataConstants.dart';

class AnchorpersonStoryPage extends StatefulWidget {
  final String anchorpersonId;
  final String anchorpersonName;
  AnchorpersonStoryPage({
    @required this.anchorpersonId,
    @required this.anchorpersonName,
  });

  @override
  _AnchorpersonStoryPageState createState() => _AnchorpersonStoryPageState();
}

class _AnchorpersonStoryPageState extends State<AnchorpersonStoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: Center(child: Text(widget.anchorpersonId)),
    );
  }

  Widget _buildBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: appBarColor,
      title: Text(widget.anchorpersonName),
    );
  }
}