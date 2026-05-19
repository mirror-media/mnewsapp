import 'package:flutter/material.dart';
import 'package:tv/helpers/dataConstants.dart';

class RouteErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text('Error'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Text('ROUTE ERROR'),
      ),
    );
  }
}
