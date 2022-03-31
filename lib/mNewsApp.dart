import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/helpers/routeGenerator.dart';

class MNewsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.logAppOpen();
    return MaterialApp(
      title: 'mnews',
      builder: (context, widget) {
        if (widget == null) {
          return Container();
        }
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
          ),
          child: widget,
        );
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      initialRoute: RouteGenerator.root,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
