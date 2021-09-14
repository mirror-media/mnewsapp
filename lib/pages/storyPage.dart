import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tv/baseConfig.dart';
import 'package:tv/blocs/story/bloc.dart';
import 'package:tv/blocs/story/events.dart';
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
  StoryBloc _bloc = StoryBloc(storyRepos: StoryServices());

  double _initTextSize = 20;
  double _selectTextSize = 20;

  @override
  void initState() {
    _slug = widget.slug;
    _getTextSizeSetting();
    super.initState();
  }

  _getTextSizeSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getDouble('textSize') == null) {
      await prefs.setDouble('textSize', 20);
    } else {
      _initTextSize = prefs.getDouble('textSize')!;
      _selectTextSize = _initTextSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildBar(context),
        body: BlocProvider(
            create: (context) => _bloc,
            child: Column(
              children: [
                Expanded(
                  child: StoryWidget(slug: _slug),
                ),
                // AnchoredBannerAdWidget(isKeepAlive: false,),
              ],
            )));
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
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return textSizeSheet();
                }).then((value) async {
              if (_selectTextSize != _initTextSize) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setDouble('textSize', _selectTextSize);
                _initTextSize = _selectTextSize;
                _bloc.add(ChangeTextSize(_selectTextSize));
              }
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.share),
          tooltip: 'Share',
          onPressed: () {
            String url = baseConfig!.mNewsWebsiteLink + 'story/' + _slug;
            Share.share(url);
          },
        ),
      ],
    );
  }

  Widget textSizeSheet() {
    return StatefulBuilder(builder: (context, myState) {
      BorderSide middleButtonBorder;
      BorderSide bigButtonBorder;
      Color middleButtonColor;
      Color bigButtonColor;
      // 20 is middle, 24 is big
      if (_selectTextSize == 20) {
        middleButtonBorder = BorderSide(color: Color(0xE5004DBC), width: 2);
        middleButtonColor = Color(0xE5004DBC);
        bigButtonBorder = BorderSide(color: Colors.transparent, width: 2);
        bigButtonColor = Color(0xE5151515);
      } else {
        bigButtonBorder = BorderSide(color: Color(0xE5004DBC), width: 2);
        bigButtonColor = Color(0xE5004DBC);
        middleButtonBorder = BorderSide(color: Colors.transparent, width: 2);
        middleButtonColor = Color(0xE5151515);
      }
      return Container(
        height: 190,
        margin: EdgeInsets.fromLTRB(60, 24, 60, 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: Text('字體大小',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton(
                    style: OutlinedButton.styleFrom(side: middleButtonBorder),
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      height: 90,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 45,
                            child: Icon(
                              Icons.format_size,
                              size: 30,
                              color: middleButtonColor,
                            ),
                          ),
                          Container(
                            height: 45,
                            padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
                            child: Text(
                              '中',
                              style: TextStyle(
                                  fontSize: 20, color: middleButtonColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      if (_selectTextSize != 20) {
                        myState(() {
                          _selectTextSize = 20;
                        });
                      }
                    }),
                OutlinedButton(
                    style: OutlinedButton.styleFrom(side: bigButtonBorder),
                    child: Container(
                      height: 90,
                      margin:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 45,
                            child: Icon(
                              Icons.format_size,
                              size: 40,
                              color: bigButtonColor,
                            ),
                          ),
                          Container(
                            height: 45,
                            padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
                            child: Text(
                              '大',
                              style: TextStyle(
                                  fontSize: 20, color: bigButtonColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      if (_selectTextSize != 24) {
                        myState(() {
                          _selectTextSize = 24;
                        });
                      }
                    }),
              ],
            )
          ],
        ),
      );
    });
  }
}
