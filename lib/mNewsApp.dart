import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tv/helpers/routeGenerator.dart';

class MNewsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mnews',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.light,
          )),
      initialRoute: RouteGenerator.root,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
