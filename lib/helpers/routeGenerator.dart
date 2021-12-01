import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/initialApp.dart';
import 'package:tv/blocs/config/bloc.dart';
import 'package:tv/models/adUnitId.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:tv/pages/section/anchorperson/anchorpersonStoryPage.dart';
import 'package:tv/pages/error/routeErrorPage.dart';
import 'package:tv/pages/search/searchPage.dart';
import 'package:tv/pages/section/topic/topicStoryListPage.dart';
import 'package:tv/pages/settingPage.dart';
import 'package:tv/pages/section/show/showStoryPage.dart';
import 'package:tv/pages/storyPage.dart';
import 'package:tv/services/configService.dart';

class RouteGenerator {
  static const String root = '/';
  static const String setting = '/setting';
  static const String search = '/search';
  static const String story = '/story';
  static const String anchorpersonStory = '/anchorpersonStory';
  static const String showStory = '/showStory';
  static const String topicStoryList = '/topicStoryList';

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
            settings: settings, builder: (_) => SettingPage());
      case search:
        return MaterialPageRoute(
            settings: settings, builder: (_) => SearchPage());
      case story:
        Map args = settings.arguments as Map<dynamic, dynamic>;
        // Validation of correct data type
        if (args['slug'] is String) {
          return MaterialPageRoute(
              settings: settings,
              builder: (context) => StoryPage(
                    slug: args['slug'],
                  ));
        }
        // If args is not of the correct type, return an error page.
        // You can also throw an exception while in development.
        return _errorRoute(settings);
      case anchorpersonStory:
        Map args = settings.arguments as Map<dynamic, dynamic>;
        // Validation of correct data type
        if (args['anchorpersonId'] is String) {
          return MaterialPageRoute(
              settings: settings,
              builder: (context) => AnchorpersonStoryPage(
                    anchorpersonId: args['anchorpersonId'],
                    anchorpersonName: args['anchorpersonName'],
                  ));
        }
        // If args is not of the correct type, return an error page.
        // You can also throw an exception while in development.
        return _errorRoute(settings);
      case showStory:
        Map args = settings.arguments as Map<dynamic, dynamic>;
        // Validation of correct data type
        if (args['youtubePlayListId'] is String &&
            args['youtubePlaylistItem'] is YoutubePlaylistItem &&
            args['adUnitId'] is AdUnitId) {
          return MaterialPageRoute(
              settings: settings,
              builder: (context) => ShowStoryPage(
                    youtubePlayListId: args['youtubePlayListId'],
                    youtubePlaylistItem: args['youtubePlaylistItem'],
                    adUnitId: args['adUnitId'],
                  ));
        }
        // If args is not of the correct type, return an error page.
        // You can also throw an exception while in development.
        return _errorRoute(settings);
      case topicStoryList:
        Map args = settings.arguments as Map<dynamic, dynamic>;
        // Validation of correct data type
        if (args['slug'] is String && args['topicName'] is String) {
          return MaterialPageRoute(
              settings: settings,
              builder: (context) => TopicStoryListPage(
                    slug: args['slug'],
                    topicName: args['topicName'],
                  ));
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
        });
  }

  static void navigateToSetting(BuildContext context) {
    Navigator.of(context).pushNamed(
      setting,
    );
  }

  static void navigateToSearch(BuildContext context) {
    Navigator.of(context).pushNamed(
      search,
    );
  }

  static void navigateToStory(BuildContext context, String slug) {
    Navigator.of(context).pushNamed(
      story,
      arguments: {
        'slug': slug,
      },
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

  static void navigateToShowStory(
    BuildContext context,
    String youtubePlayListId,
    YoutubePlaylistItem youtubePlaylistItem,
    AdUnitId adUnitId,
    bool isMoreShow,
  ) {
    if (isMoreShow) {
      Navigator.of(context).popAndPushNamed(
        showStory,
        arguments: {
          'youtubePlayListId': youtubePlayListId,
          'youtubePlaylistItem': youtubePlaylistItem,
          'adUnitId': adUnitId
        },
      );
    } else {
      Navigator.of(context).pushNamed(
        showStory,
        arguments: {
          'youtubePlayListId': youtubePlayListId,
          'youtubePlaylistItem': youtubePlaylistItem,
          'adUnitId': adUnitId
        },
      );
    }
  }

  static void navigateToTopicStoryListPage(
    BuildContext context,
    String topicName,
    String slug,
  ) {
    Navigator.of(context).pushNamed(
      topicStoryList,
      arguments: {'slug': slug, 'topicName': topicName},
    );
  }

  static void printRouteSettings(BuildContext context) {
    var route = ModalRoute.of(context);
    if (route != null) {
      print('route is current: ${route.isCurrent}');
      print('route name: ${route.settings.name}');
      print('route arg: ${route.settings.arguments.toString()}');
    }
  }
}
