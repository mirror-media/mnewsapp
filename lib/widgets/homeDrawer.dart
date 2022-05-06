import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tv/blocs/section/section_cubit.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/section.dart';
import 'package:tv/models/topic.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeDrawer extends StatefulWidget {
  final List<Topic> topics;
  const HomeDrawer(this.topics);
  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  final sectionCubit = SectionCubit();
  _changeSection(MNewsSection sectionId) {
    context.read<SectionCubit>().changeSection(sectionId);
  }

  final TextScaleFactorController textScaleFactorController = Get.find();

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
                child: Container(
                  color: drawerColor,
                  child: SafeArea(
                    bottom: false,
                    child: _buildDrawerHeader(padding),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _drawerButtonBlock(sectionId)),
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
      // height: 84.0 + padding.top,
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
    List<Section> sectionList = List<Section>.from(Environment()
        .config
        .mNewsSectionList
        .map((section) => Section.fromJson(section)));

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
                    Obx(
                      () => Text(
                        sectionList[index].name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: sectionId == sectionList[index].id
                              ? Color(0xff004DBC)
                              : null,
                        ),
                        textScaleFactor:
                            textScaleFactorController.textScaleFactor.value,
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

  Widget _thirdPartyMediaLinkButton(IconData icon, String title, String link) {
    return InkWell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                width: 18,
                alignment: Alignment.center,
                child: FaIcon(
                  icon,
                  size: 18,
                  color: Color(0xff757575),
                ),
              ),
              SizedBox(width: 16.0),
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
          Uri? uri = Uri.tryParse(link);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri);
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
                      '鏡新聞 YouTube 頻道',
                      'https://www.youtube.com/channel/UC4LjkybVKXCDlneVXlKAbmw'),
                  _thirdPartyMediaLinkButton(FontAwesomeIcons.facebookSquare,
                      '鏡新聞 粉絲專頁', 'https://www.facebook.com/mnewstw'),
                  _thirdPartyMediaLinkButton(FontAwesomeIcons.instagram,
                      '鏡新聞 Instagram', 'https://www.instagram.com/mnewstw/'),
                  _thirdPartyMediaLinkButton(
                      Icons.email, '聯絡我們', 'mailto:mnews.cs@mnews.tw'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
