import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/categories/bloc.dart';
import 'package:tv/blocs/categories/events.dart';
import 'package:tv/blocs/categories/states.dart';
import 'package:tv/blocs/newsMarquee/bloc.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/category.dart';
import 'package:tv/models/categoryList.dart';
import 'package:tv/services/newsMarqueeService.dart';
import 'package:tv/widgets/newsMarqueeWidget.dart';
import 'package:tv/widgets/tabContent.dart';

class CategoryTab extends StatefulWidget {
  @override
  _CategoryTabState createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> with TickerProviderStateMixin{
  /// tab controller
  int _initialTabIndex;
  TabController _tabController;

  List<Tab> _tabs;
  List<Widget> _tabWidgets;

  @override
  void initState() {
    /// tab controller
    _initialTabIndex = 0;
    _tabs = List<Tab>();
    _tabWidgets = List<Widget>();

    _loadCategoryList();
    super.initState();
  }

  _loadCategoryList() async {
    context.read<CategoriesBloc>().add(CategoryEvents.fetchCategories);
  }

  _initializeTabController(CategoryList categoryList) {
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

      _tabWidgets.add(
        TabContent(
          categorySlug: category.slug,
          needCarousel: categoryList[i].isLatestCategory(),
        ),
      );
    }

    // set controller
    _tabController = TabController(
      vsync: this,
      length: categoryList.length,
      initialIndex:
          _tabController == null ? _initialTabIndex : _tabController.index,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (BuildContext context, CategoriesState state) {
        if (state is CategoriesError) {
          final error = state.error;
          String message = '${error.message}\nTap to Retry.';
          return Center(
            child: Text(message),
          );
        }
        if (state is CategoriesLoaded) {
          CategoryList categoryList = state.categoryList;
          _initializeTabController(categoryList);
          
          return _buildTabs(_tabs, _tabWidgets, _tabController);
        }

        // state is Init, loading, or other 
        return _loadingWidget();
      }
    );
  }

  Widget _loadingWidget() =>
      Center(
        child: CircularProgressIndicator(),
      );

  Widget _buildTabs(
      List<Tab> tabs, List<Widget> tabWidgets, TabController tabController) {
    return Column(
      children: [
        Container(
          constraints: BoxConstraints(maxHeight: 150.0),
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
          create: (context) => NewsMarqueeBloc(newsMarqueeRepos: NewsMarqueeServices()),
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