import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/controller/show_category_controller.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/category.dart';
import 'package:tv/pages/section/show/election_widget/election_controller.dart';
import 'package:tv/pages/section/show/election_widget/election_widget.dart';
import 'package:tv/pages/section/show/showTabContent.dart';

class ShowCategoryTab extends StatefulWidget {
  const ShowCategoryTab({super.key});

  @override
  State<ShowCategoryTab> createState() => _ShowCategoryTabState();
}

class _ShowCategoryTabState extends State<ShowCategoryTab>
    with TickerProviderStateMixin {
  final ShowCategoryController controller = Get.find();

  int initialTabIndex = 0;
  TabController? tabController;
  final List<Tab> tabs = List.empty(growable: true);
  final List<Widget> tabWidgets = List.empty(growable: true);

  void initializeTabController(List<Category> categoryList) {
    tabs.clear();
    tabWidgets.clear();

    for (final category in categoryList) {
      tabs.add(
        Tab(
          child: Obx(
            () => Text(
              category.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textScaleFactor:
                  Get.find<TextScaleFactorController>().textScaleFactor.value,
            ),
          ),
        ),
      );

      if (category.slug!.contains('election')) {
        tabWidgets.add(
          ElectionWidget(tag: category.slug ?? ''),
        );
      } else {
        tabWidgets.add(
          ShowTabContent(category: category),
        );
      }
    }

    tabController = TabController(
      vsync: this,
      length: categoryList.length,
      initialIndex: tabController == null ? initialTabIndex : tabController!.index,
    );

    tabController?.addListener(() {
      final tag = categoryList[tabController!.index].slug!;
      if (tag.contains('election')) {
        if (Get.isRegistered<ElectionController>(tag: tag)) {
          Get.delete<ElectionController>(tag: tag);
        }
        Get.put(ElectionController(tag), tag: tag);
      }
    });
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = controller.error.value;
      if (error != null) {
        if (error is NoInternetException) {
          return error.renderWidget(onPressed: controller.fetchCategories);
        }

        return error.renderWidget(isNoButton: true);
      }

      final categoryList = controller.categoryList;
      if (categoryList.isNotEmpty) {
        initializeTabController(categoryList);
        return buildTabs(tabs, tabWidgets, tabController!);
      }

      return loadingWidget();
    });
  }

  Widget loadingWidget() {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }

  Widget buildTabs(
    List<Tab> tabs,
    List<Widget> tabWidgets,
    TabController tabController,
  ) {
    return Column(
      children: [
        Container(
          color: tabBarColor,
          width: double.infinity,
          alignment: Alignment.topCenter,
          child: Material(
            color: tabBarColor,
            child: TabBar(
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              indicatorColor: tabBarSelectedColor,
              unselectedLabelColor: tabBarUnselectedColor,
              labelColor: tabBarSelectedColor,
              tabs: tabs.toList(),
              controller: tabController,
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: tabWidgets.toList(),
          ),
        ),
      ],
    );
  }
}
