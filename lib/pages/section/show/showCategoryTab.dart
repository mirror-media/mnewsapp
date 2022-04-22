import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/categories/bloc.dart';
import 'package:tv/blocs/categories/events.dart';
import 'package:tv/blocs/categories/states.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/category.dart';
import 'package:tv/pages/section/show/showTabContent.dart';

class ShowCategoryTab extends StatefulWidget {
  @override
  _ShowCategoryTabState createState() => _ShowCategoryTabState();
}

class _ShowCategoryTabState extends State<ShowCategoryTab>
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
    context.read<CategoriesBloc>().add(FetchCategories());
  }

  _initializeTabController(List<Category> categoryList) {
    _tabs.clear();
    _tabWidgets.clear();

    for (int i = 0; i < categoryList.length; i++) {
      Category category = categoryList[i];
      _tabs.add(
        Tab(
          child: Text(
            category.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      _tabWidgets.add(ShowTabContent(
        category: category,
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
        print('ShowCategoriesError: ${error.message}');
        if (error is NoInternetException) {
          return error.renderWidget(onPressed: () => _loadCategoryList());
        }

        return error.renderWidget(isNoButton: true);
      }
      if (state is CategoriesLoaded) {
        List<Category> categoryList = state.categoryList;
        _initializeTabController(categoryList);

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
