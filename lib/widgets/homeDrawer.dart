import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeDrawer extends StatefulWidget {
  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 84.0 + padding.top,
            child: DrawerHeader(
              margin: null,
              decoration: BoxDecoration(
                color: Color(0xff004DBC),
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
          ),
          _drawerButton(
            '新聞', 
            true, 
            (){
              print('新聞');
            }
          ),
          _dividerBlock(),
          _drawerButton(
            '直播', 
            false, 
            (){
              print('直播');
            }
          ),
          _dividerBlock(),
          _drawerButton(
            '影音', 
            false, 
            (){
              print('影音');
            }
          ),
          _dividerBlock(),
          _drawerButton(
            '節目', 
            false, 
            (){
              print('節目');
            }
          ),
          _anchorBlock(height),
          _thirdPartyMediaLinkButton(
            FontAwesomeIcons.youtube , 
            '鏡電視 YouTube 頻道', 
            'https://www.google.com/'
          ),
          _thirdPartyMediaLinkButton(
            FontAwesomeIcons.facebookSquare , 
            '鏡電視 粉絲專頁', 
            'https://www.google.com/'
          ),
          _thirdPartyMediaLinkButton(
            FontAwesomeIcons.instagram , 
            '鏡電視 Instagram', 
            'https://www.google.com/'
          ),
        ],
      ),
    );
  }

  Widget _drawerButton(String title, bool isSelected, Function function) {
    return InkWell(
      child: Row(
        children: [
          Container(
            width: 8.0, 
            height: 56,
            color: isSelected? Color(0xffFFCC00) : null,
          ),
          SizedBox(width: 8.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: isSelected? Color(0xff004DBC) : null,
            ),
          ),
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

  Widget _anchorBlock(double height) {
    return Container(
      color: Color(0xffF4F5F6),
      height: height/3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.mic),
                SizedBox(width: 15),
                Text('鏡主播'),
              ],
            ),
          ),
        ],
      ),
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
}