import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/section/section_cubit.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/helpers/routeGenerator.dart';
import 'package:tv/models/sectionList.dart';
import 'package:tv/models/topicList.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeDrawer extends StatefulWidget {
  final TopicList topics;
  const HomeDrawer(this.topics);
  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  final sectionCubit = SectionCubit();
  _changeSection(MNewsSection sectionId) {
    context.read<SectionCubit>().changeSection(sectionId);
  }

  @override
  Widget build(BuildContext context) {
    //var height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;

    return BlocBuilder<SectionCubit, SectionStateCubit>(
        builder: (BuildContext context, SectionStateCubit state) {
      if (state is SectionError) {
        final error = state.error;
        print('SectionError: ${error.message}');
        return Container();
      } else {
        MNewsSection sectionId = state.sectionId;

        return Drawer(
          child: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildDrawerHeader(padding),
              ),
              SliverToBoxAdapter(child: _drawerButtonBlock(sectionId)),
              SliverToBoxAdapter(child: _topicsButton()),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  color: Colors.white,
                  alignment: Alignment.bottomCenter,
                  child: _thirdPartyBlock(),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget _buildDrawerHeader(EdgeInsets padding) {
    return Container(
      height: 84.0 + padding.top,
      // Add color back
      color: drawerColor,
      //Temporarily remove the login and setting buttons
      /*child: DrawerHeader(
        margin: null,
        decoration: BoxDecoration(
          color: drawerColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '登入 / 註冊',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
                SizedBox(width: 8.0),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                )
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.white,
              ), 
              onPressed: () => RouteGenerator.navigateToSetting(context),
            ),
          ]
        ),
      ),*/
    );
  }

  Widget _drawerButton(Widget child, bool isSelected, Function function) {
    return InkWell(
        child: Container(
          color: Colors.white,
          child: Row(
            children: [
              Container(
                width: 12.0,
                height: 56,
                color: isSelected ? Color(0xffFFCC00) : null,
              ),
              SizedBox(width: 12.0),
              child,
            ],
          ),
        ),
        onTap: function as void Function()?);
  }

  Widget _dividerBlock(double leftMargin) => Container(
        margin: EdgeInsets.only(left: leftMargin),
        height: 0.5,
        color: Colors.grey[350],
      );

  Widget _drawerButtonBlock(MNewsSection sectionId) {
    SectionList sectionList =
        SectionList.fromJson(Environment().config.mNewsSectionList);

    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0.0),
        itemCount: sectionList.length,
        itemBuilder: (context, index) {
          return Column(children: [
            _drawerButton(
                Row(
                  children: [
                    Text(
                      sectionList[index].name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: sectionId == sectionList[index].id
                            ? Color(0xff004DBC)
                            : null,
                      ),
                    ),
                    if (sectionList[index].id == MNewsSection.live) ...[
                      SizedBox(width: 8),
                      FaIcon(
                        FontAwesomeIcons.podcast,
                        size: 18,
                        color: Colors.red,
                      ),
                    ],
                  ],
                ),
                sectionId == sectionList[index].id, () async {
              _changeSection(sectionList[index].id);
              await Future.delayed(Duration(milliseconds: 150));
              Navigator.of(context).pop();
            }),
            _dividerBlock(index == sectionList.length - 1 ? 0 : 16.0),
          ]);
        });
  }

  Widget _topicsButton() {
    List<Widget> topicButtons = [];

    if (widget.topics.isNotEmpty) {
      for (var topic in widget.topics) {
        if (topic.isFeatured) {
          topicButtons.add(Container(
            alignment: Alignment.centerLeft,
            width: 90,
            height: 40,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                RouteGenerator.navigateToTopicStoryListPage(
                  context,
                  topic,
                );
              },
              child: Text(
                topic.name,
                maxLines: 1,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
              style: TextButton.styleFrom(
                primary: Color.fromRGBO(0, 77, 188, 1),
              ),
            ),
          ));
        }
      }

      String buttonText = '所有專題';

      if (topicButtons.isNotEmpty) {
        buttonText = '更多專題';
      }
      topicButtons.add(Container(
        padding: EdgeInsets.only(right: 20),
        alignment: Alignment.centerLeft,
        width: 100,
        height: 40,
        child: TextButton(
          onPressed: () async {
            _changeSection(MNewsSection.topicList);
            await Future.delayed(Duration(milliseconds: 150));
            Navigator.of(context).pop();
          },
          child: Text(
            buttonText,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          style: TextButton.styleFrom(
            primary: Color.fromRGBO(117, 117, 117, 1),
          ),
        ),
      ));
    }

    return Container(
      color: Colors.white,
      child: Wrap(
        children: topicButtons,
      ),
      padding: EdgeInsets.only(top: 20, left: 20),
    );
  }

  Widget _thirdPartyMediaLinkButton(IconData icon, String title, String link) {
    return InkWell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              FaIcon(
                icon,
                size: 18,
                color: Color(0xff757575),
              ),
              icon == FontAwesomeIcons.youtube
                  ? SizedBox(width: 13.0)
                  : SizedBox(width: 16.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        onTap: () async {
          if (await canLaunch(link)) {
            await launch(link);
          } else {
            throw 'Could not launch $link';
          }
        });
  }

  Widget _thirdPartyBlock() {
    return Container(
      // real size is 143 ((15*1.4+16)*3+32)
      //height: 150,
      color: Color.fromRGBO(244, 245, 246, 1),
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 24, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _thirdPartyMediaLinkButton(
                      FontAwesomeIcons.youtube,
                      '鏡電視 YouTube 頻道',
                      'https://www.youtube.com/channel/UC4LjkybVKXCDlneVXlKAbmw'),
                  _thirdPartyMediaLinkButton(FontAwesomeIcons.facebookSquare,
                      '鏡電視 粉絲專頁', 'https://www.facebook.com/mnewstw'),
                  _thirdPartyMediaLinkButton(FontAwesomeIcons.instagram,
                      '鏡電視 Instagram', 'https://www.instagram.com/mnewstw/'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
