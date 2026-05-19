import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/bindings/ombuds_binding.dart';
import 'package:tv/controller/ombuds_controller.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/pages/section/ombuds/ombuds_widget.dart';

class OmbudsPage extends StatefulWidget {
  const OmbudsPage({super.key});

  @override
  State<OmbudsPage> createState() => _OmbudsPageState();
}

class _OmbudsPageState extends State<OmbudsPage> {
  @override
  void initState() {
    super.initState();
    OmbudsBinding().dependencies();
  }

  @override
  void dispose() {
    if (Get.isRegistered<OmbudsController>()) {
      Get.delete<OmbudsController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.sendScreenView(screenName: 'OmbudsPage');
    return const Center(
      child: OmbudsWidget(),
    );
  }
}
