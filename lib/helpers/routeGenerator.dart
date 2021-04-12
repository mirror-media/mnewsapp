import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/initialApp.dart';
import 'package:tv/blocs/config/bloc.dart';
import 'package:tv/pages/anchorpersonStoryPage.dart';
import 'package:tv/pages/routeErrorPage.dart';
import 'package:tv/pages/settingPage.dart';
import 'package:tv/services/configService.dart';

class RouteGenerator {
  static const String root = '/';
  static const String setting = '/setting';
  static const String anchorpersonStory = '/anchorpersonStory';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case root:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (context) => ConfigBloc(configRepos: ConfigServices()),
            child: InitialApp(),
          ),
        );
      case setting:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SettingPage()
        );
      case anchorpersonStory:
        Map args = settings.arguments;
        // Validation of correct data type
        if (args['anchorpersonId'] is String) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => AnchorpersonStoryPage(
              anchorpersonId: args['anchorpersonId'],
              anchorpersonName: args['anchorpersonName'],
            )
          );
        }
        // If args is not of the correct type, return an error page.
        // You can also throw an exception while in development.
        return _errorRoute(settings);
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute(settings);
    }
  }

  static Route<dynamic> _errorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) {
        return RouteErrorPage();
      }
    );
  }

  static void navigateToSetting(BuildContext context) {
    Navigator.of(context).pushNamed(
      setting,
    );
  }

  static void navigateToAnchorpersonStory(
    BuildContext context, 
    String anchorpersonId,
    String anchorpersonName,
  ) {
    Navigator.of(context).pushNamed(
      anchorpersonStory,
      arguments: {
        'anchorpersonId': anchorpersonId,
        'anchorpersonName': anchorpersonName,
      },
    );
  }

  static void printRouteSettings(BuildContext context) {
    var route = ModalRoute.of(context);
    if(route!=null){
      print('route is current: ${route.isCurrent}');
      print('route name: ${route.settings.name}');
      print('route arg: ${route.settings.arguments.toString()}');
    }
  }
}