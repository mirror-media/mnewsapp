import 'package:flutter/material.dart';
import 'package:tv/widgets/homeDrawer.dart';

class InitialApp extends StatefulWidget {
  @override
  _InitialAppState createState() => _InitialAppState();
}

class _InitialAppState extends State<InitialApp> {
  var _scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      drawer: HomeDrawer(),
      appBar: _buildBar(context, _scaffoldkey),
      body: Center(
        child: Text(
          'mnews',
        ),
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
      backgroundColor: Color(0xff003366),
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