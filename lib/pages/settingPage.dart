import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/notificationSetting/bloc.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/services/notificationSettingService.dart';
import 'package:tv/widgets/notificationSettingWidget.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(
            child: BlocProvider(
              create: (context) => NotificationSettingBloc(
                  notificationSettingRepos: NotificationSettingServices()),
              child: NotificationSettingWidget(),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(height: 120, child: _moreInfo(context))),
          ),
        ]),
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
      title: Text('設定'),
    );
  }

  Widget _moreInfo(BuildContext context) {
    return Wrap(children: [
      Divider(),
      SizedBox(height: 8),
      InkWell(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: Row(children: [
              Icon(
                Icons.apps,
                color: Color(0xff757575),
              ),
              SizedBox(width: 12),
              Text(
                '看更多應用程式',
                style: TextStyle(color: Color(0xff757575), fontSize: 16.0),
              ),
            ]),
          ),
          onTap: () {}),
      InkWell(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: Row(children: [
              Icon(
                Icons.info,
                color: Color(0xff757575),
              ),
              SizedBox(width: 12),
              Text(
                '鏡電視行動應用程式資訊',
                style: TextStyle(color: Color(0xff757575), fontSize: 16.0),
              ),
            ]),
          ),
          onTap: () {}),
      SizedBox(height: 8),
    ]);
  }
}
