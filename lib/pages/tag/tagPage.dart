import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/tag/bloc.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/tag.dart';
import 'package:tv/pages/tag/tagWidget.dart';

class TagPage extends StatefulWidget {
  final Tag tag;
  const TagPage({
    required this.tag,
  });

  @override
  _TagPageState createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  late Tag _tag;

  @override
  void initState() {
    _tag = widget.tag;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      backgroundColor: Colors.white,
      body: BlocProvider(
        create: (context) => TagStoryListBloc(),
        child: SafeArea(
          child: TagWidget(_tag),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: appBarColor,
      centerTitle: true,
      title: Text(
        _tag.name,
        style: const TextStyle(color: Colors.white, fontSize: 17),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
