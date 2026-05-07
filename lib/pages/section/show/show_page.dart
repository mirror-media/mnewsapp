import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/bindings/show_binding.dart';
import 'package:tv/controller/show_category_controller.dart';
import 'package:tv/pages/section/show/show_category_tab.dart';

class ShowPage extends StatefulWidget {
  const ShowPage({super.key});

  @override
  State<ShowPage> createState() => _ShowPageState();
}

class _ShowPageState extends State<ShowPage> {
  @override
  void initState() {
    super.initState();
    ShowBinding().dependencies();
  }

  @override
  void dispose() {
    if (Get.isRegistered<ShowCategoryController>()) {
      Get.delete<ShowCategoryController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const ShowCategoryTab();
  }
}
