import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/bindings/notification_setting_binding.dart';
import 'package:tv/controller/notification_setting_controller.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/widgets/notificationSettingWidget.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  void initState() {
    super.initState();
    NotificationSettingBinding().dependencies();
  }

  @override
  void dispose() {
    if (Get.isRegistered<NotificationSettingController>()) {
      Get.delete<NotificationSettingController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: SafeArea(
        child: CustomScrollView(slivers: [
          const SliverToBoxAdapter(
            child: NotificationSettingWidget(),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(height: 120, child: _moreInfo(context)),
            ),
          ),
        ]),
      ),
    );
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: appBarColor,
      title: const Text('設定'),
    );
  }

  Widget _moreInfo(BuildContext context) {
    return Wrap(children: [
      const Divider(),
      const SizedBox(height: 8),
      InkWell(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: Row(children: [
              const Icon(
                Icons.apps,
                color: Color(0xff757575),
              ),
              const SizedBox(width: 12),
              const Text(
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
              const Icon(
                Icons.info,
                color: Color(0xff757575),
              ),
              const SizedBox(width: 12),
              const Text(
                '鏡電視行動應用程式資訊',
                style: TextStyle(color: Color(0xff757575), fontSize: 16.0),
              ),
            ]),
          ),
          onTap: () {}),
      const SizedBox(height: 8),
    ]);
  }
}
