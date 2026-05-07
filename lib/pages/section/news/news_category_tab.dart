import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tv/controller/news_category_controller.dart';
import 'package:tv/controller/text_scale_factor_controller.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/category.dart';
import 'package:tv/pages/section/news/latestTabContent/latest_tab_content.dart';
import 'package:tv/pages/section/news/news_tab_content.dart';
import 'package:tv/widgets/news_marquee/news_marquee_widget.dart';

class NewsCategoryTab extends StatefulWidget {
  const NewsCategoryTab({super.key});

  @override
  State<NewsCategoryTab> createState() => _NewsCategoryTabState();
}

class _NewsCategoryTabState extends State<NewsCategoryTab>
    with TickerProviderStateMixin {
  final NewsCategoryController controller = Get.find();

  int initialTabIndex = 0;
  TabController? tabController;
  final List<Tab> tabs = List.empty(growable: true);
  final List<Widget> tabWidgets = List.empty(growable: true);

  void initializeTabController(List<Category> categoryList) {
    tabs.clear();
    tabWidgets.clear();

    for (int i = 0; i < categoryList.length; i++) {
      final category = categoryList[i];
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

      tabWidgets.add(
        category.slug == 'latest'
            ? const LatestTabContent()
            : NewsTabContent(
                categorySlug: category.slug!,
                needCarousel: categoryList[i].isLatestCategory(),
                showElectionBlock: i == 0,
              ),
      );
    }

    tabController = TabController(
      vsync: this,
      length: categoryList.length,
      initialIndex: tabController == null ? initialTabIndex : tabController!.index,
    );
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
        const Padding(
          padding: EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 12.0),
          child: BuildNewsMarquee(tag: 'news_marquee'),
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
