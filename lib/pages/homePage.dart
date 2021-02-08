import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/categories/bloc.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/services/categoryService.dart';
import 'package:tv/widgets/categoryTab.dart';
import 'package:tv/widgets/homeDrawer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      drawer: HomeDrawer(),
      appBar: _buildBar(context, _scaffoldkey),
      body: BlocProvider(
        create: (context) => CategoriesBloc(categoryRepos: CategoryServices()),
        child: CategoryTab(),
      ),
    );
  }

    Widget _buildBar(BuildContext context, GlobalKey<ScaffoldState> scaffoldkey) {
      return AppBar(
        elevation: 0.1,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => scaffoldkey.currentState.openDrawer()
        ),
        backgroundColor: appBarColor,
        centerTitle: true,
        title: Text('鏡新聞'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {},
          ),
        ],
      );
    }
}