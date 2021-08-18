import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share/share.dart';
import 'package:tv/blocs/story/bloc.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/services/storyService.dart';
import 'package:tv/widgets/anchoredBannerAdWidget.dart';
import 'package:tv/widgets/storyWidget.dart';

class StoryPage extends StatefulWidget {
  final String slug;
  StoryPage({
    required this.slug,
  });

  @override
  _StoryPageState createState() => _StoryPageState();

  static _StoryPageState? of(BuildContext context) =>
    context.findAncestorStateOfType<_StoryPageState>();
}

class _StoryPageState extends State<StoryPage> {
  late String _slug;
  set slug(String value) => _slug = value;

  @override
  void initState() {
    _slug = widget.slug;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: BlocProvider(
        create: (context) => StoryBloc(storyRepos: StoryServices()),
        child: Column(
          children: [
            Expanded(
              child: StoryWidget(slug: _slug),
            ),
            AnchoredBannerAdWidget(),
          ],
        )
      ),
    );
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: appBarColor,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.text_fields),
          tooltip: 'Change text size',
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.share),
          tooltip: 'Share',
          onPressed: () {
            String url = mNewsWebsiteLink + 'story/' +  _slug;
            Share.share(url);
          },
        ),
      ],
    );
  }
}