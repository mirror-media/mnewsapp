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
      supportedLocales: [
        const Locale.fromSubtags(languageCode: 'zh'),
        const Locale('en', 'US'),
      ],
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
