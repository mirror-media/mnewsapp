import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:tv/blocs/categories/bloc.dart';
import 'package:tv/blocs/categories/events.dart';
import 'package:tv/blocs/categories/states.dart';
import 'package:tv/blocs/newsMarquee/bloc.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/category.dart';
import 'package:tv/services/newsMarqueeService.dart';
import 'package:tv/pages/shared/newsMarquee/newsMarqueeWidget.dart';
import 'package:tv/pages/section/video/videoTabContent.dart';
///棄用 待刪除
class VideoCategoryTab extends StatefulWidget {
  @override
  _VideoCategoryTabState createState() => _VideoCategoryTabState();
}

class _VideoCategoryTabState extends State<VideoCategoryTab>
    with TickerProviderStateMixin {
  /// tab controller
  int _initialTabIndex = 0;
  TabController? _tabController;

  List<Tab> _tabs = List.empty(growable: true);
  List<Widget> _tabWidgets = List.empty(growable: true);

  @override
  void initState() {
    _loadCategoryList();
    super.initState();
  }

  _loadCategoryList() async {
    context.read<CategoriesBloc>().add(FetchVideoCategories());
  }

  _initializeTabController(
      List<Category> categoryList, bool hasEditorChoice, bool hasPopular) {
    _tabs.clear();
    _tabWidgets.clear();
    if (!hasPopular) {
      categoryList.removeAt(1);
    }

    if (!hasEditorChoice) {
      categoryList.removeAt(0);
    }

    for (int i = 0; i < categoryList.length; i++) {
      Category category = categoryList[i];
      _tabs.add(
        Tab(
          child: Obx(
            () => Text(
              category.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textScaleFactor:
                  Get.find<TextScaleFactorController>().textScaleFactor.value,
            ),
          ),
        ),
      );

      _tabWidgets.add(VideoTabContent(
        categorySlug: category.slug!,
        isFeaturedSlug: categoryList[i].isFeaturedCategory(),
      ));
    }

    // set controller
    _tabController = TabController(
      vsync: this,
      length: categoryList.length,
      initialIndex:
          _tabController == null ? _initialTabIndex : _tabController!.index,
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (BuildContext context, CategoriesState state) {
      if (state is CategoriesError) {
        final error = state.error!;
        print('NewsCategoriesError: ${error.message}');
        if (error is NoInternetException) {
          return error.renderWidget(onPressed: () => _loadCategoryList());
        }

        return error.renderWidget(isNoButton: true);
      }
      if (state is VideoCategoriesLoaded) {
        List<Category> categoryList = state.categoryList;
        _initializeTabController(
            categoryList, state.hasEditorChoice, state.hasPopular);

        return _buildTabs(_tabs, _tabWidgets, _tabController!);
      }

      // state is Init, loading, or other
      return _loadingWidget();
    });
  }

  Widget _loadingWidget() => Center(
        child: CircularProgressIndicator.adaptive(),
      );

  Widget _buildTabs(
      List<Tab> tabs, List<Widget> tabWidgets, TabController tabController) {
    return Column(
      children: [
        Container(
          color: tabBarColor,
          width: double.infinity,
          alignment: Alignment.topCenter,
          child: Material(
            color: tabBarColor,
            child: TabBar(
              isScrollable: true,
              indicatorColor: tabBarSelectedColor,
              unselectedLabelColor: tabBarUnselectedColor,
              labelColor: tabBarSelectedColor,
              tabs: tabs.toList(),
              controller: tabController,
            ),
          ),
        ),
        BlocProvider(
          create: (context) =>
              NewsMarqueeBloc(newsMarqueeRepos: NewsMarqueeServices()),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 12.0),
            child: BuildNewsMarquee(),
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
