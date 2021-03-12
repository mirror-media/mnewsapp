import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/section/bloc.dart';
import 'package:tv/blocs/section/events.dart';
import 'package:tv/blocs/section/states.dart';
import 'package:tv/models/mNewsSection.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeDrawer extends StatefulWidget {
  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  _changeSection(MNewsSection section) {
    context.read<SectionBloc>().add(ChangeSection(section));
  }

  @override
  Widget build(BuildContext context) {
    //var height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;

    return BlocBuilder<SectionBloc, SectionState>(
      builder: (BuildContext context, SectionState state) {
        if (state is SectionError) {
          final error = state.error;
          String message = '${error.message}\nTap to Retry.';
          return Center(
            child: Text(message),
          );
        } else {
          MNewsSection section = state.section;
          
          return Drawer(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildDrawerHeader(padding),),
                SliverToBoxAdapter(child: _drawerButtonBlock(MNewsSectionStringList[section.index])),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _thirdPartyBlock(),
                  ),
                ),
              ],
            ),
          );
        }
      }
    );
  }

  Widget _buildDrawerHeader(EdgeInsets padding) {
    return Container(
      height: 84.0 + padding.top,
      child: DrawerHeader(
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
              onPressed: () {
                print('go to setting');
              }
            ),
          ]
        ),
      ),
    );
  }

  Widget _drawerButton(Widget child, bool isSelected, Function function) {
    return InkWell(
      child: Row(
        children: [
          Container(
            width: 12.0, 
            height: 56,
            color: isSelected? Color(0xffFFCC00) : null,
          ),
          SizedBox(width: 12.0),
          child,
        ],
      ),
      onTap: function
    );
  }

  Widget _dividerBlock() => Container(
    margin: const EdgeInsets.only(left: 16.0),
    height: 0.5,
    color: Colors.grey,
  );

  Widget _drawerButtonBlock(String selectString) {
    return Column(
      children: [
        _drawerButton(
          Text(
            '新聞',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: selectString == '新聞' ? Color(0xff004DBC) : null,
            ),
          ),
          selectString == '新聞', 
          (){
            _changeSection(MNewsSection.news);
          }
        ),
        _dividerBlock(),
        _drawerButton(
          Text(
            '直播',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: selectString == '直播' ? Color(0xff004DBC) : null,
            ),
          ),
          selectString == '直播', 
          (){
            _changeSection(MNewsSection.live);
          }
        ),
        _dividerBlock(),
        _drawerButton(
          Text(
            '影音',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: selectString == '影音' ? Color(0xff004DBC) : null,
            ),
          ),
          selectString == '影音', 
          (){
            _changeSection(MNewsSection.media);
          }
        ),
        _dividerBlock(),
        _drawerButton(
          Text(
            '節目',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: selectString == '節目' ? Color(0xff004DBC) : null,
            ),
          ),
          selectString == '節目', 
          (){
            _changeSection(MNewsSection.show);
          }
        ),
        _dividerBlock(),
        _drawerButton(
          Row(
            children: [
              Icon(
                Icons.mic_none,
              ),
              SizedBox(width: 12),
              Text(
                '鏡主播',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: selectString == '鏡主播' ? Color(0xff004DBC) : null,
                ),
              ),
            ],
          ),
          selectString == '鏡主播', 
          (){
            _changeSection(MNewsSection.vocal);
          }
        ),
        _dividerBlock(),
      ]
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
      onTap: () async{
        if (await canLaunch(link)) {
          await launch(link);
        } else {
          throw 'Could not launch $link';
        }
      }
    );
  }

  Widget _thirdPartyBlock() {
    return Container(
      // real size is 143 ((15*1.4+16)*3+32)
      height: 150,
      color: Color(0xffF4F5F6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
        child: Column(
          children: [
            _thirdPartyMediaLinkButton(
              FontAwesomeIcons.youtube , 
              '鏡電視 YouTube 頻道', 
              'https://www.youtube.com/channel/UCYkldEK001GxR884OZMFnRw'
            ),
            _thirdPartyMediaLinkButton(
              FontAwesomeIcons.facebookSquare , 
              '鏡電視 粉絲專頁', 
              'https://www.facebook.com/mirrormediamg/'
            ),
            _thirdPartyMediaLinkButton(
              FontAwesomeIcons.instagram , 
              '鏡電視 Instagram', 
              'https://www.instagram.com/mirror_media/?hl=zh-tw'
            ),
          ]
        ),
      ),
    );
  }
}