import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/bindings/show_intro_binding.dart';
import 'package:tv/controller/show_intro_controller.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/models/category.dart';
import 'package:tv/pages/section/show/showIntroWidget.dart';

class ShowTabContent extends StatefulWidget {
  const ShowTabContent({
    super.key,
    required this.category,
  });

  final Category category;

  @override
  State<ShowTabContent> createState() => _ShowTabContentState();
}

class _ShowTabContentState extends State<ShowTabContent> {
  @override
  void initState() {
    super.initState();
    ShowIntroBinding(widget.category.id!).dependencies();
  }

  @override
  void dispose() {
    final tag = widget.category.id!;
    if (Get.isRegistered<ShowIntroController>(tag: tag)) {
      Get.delete<ShowIntroController>(tag: tag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.sendScreenView(
      screenName: 'ShowPage categoryName=${widget.category.name}',
    );
    return BuildShowIntro(
      showCategoryId: widget.category.id!,
    );
  }
}
