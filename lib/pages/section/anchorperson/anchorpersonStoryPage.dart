import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/bindings/anchorperson_story_binding.dart';
import 'package:tv/controller/contact_detail_controller.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/pages/section/anchorperson/anchorpersonStoryWidget.dart';

class AnchorpersonStoryPage extends StatefulWidget {
  final String anchorpersonId;
  final String anchorpersonName;
  AnchorpersonStoryPage({
    required this.anchorpersonId,
    required this.anchorpersonName,
  });

  @override
  _AnchorpersonStoryPageState createState() => _AnchorpersonStoryPageState();
}

class _AnchorpersonStoryPageState extends State<AnchorpersonStoryPage> {
  @override
  void initState() {
    super.initState();
    AnchorpersonStoryBinding(widget.anchorpersonId).dependencies();
  }

  @override
  void dispose() {
    if (Get.isRegistered<ContactDetailController>(tag: widget.anchorpersonId)) {
      Get.delete<ContactDetailController>(tag: widget.anchorpersonId);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: AnchorpersonStoryWidget(
        anchorpersonId: widget.anchorpersonId,
      ),
    );
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: Get.back,
      ),
      backgroundColor: appBarColor,
      centerTitle: true,
      title: Text(widget.anchorpersonName),
    );
  }
}
