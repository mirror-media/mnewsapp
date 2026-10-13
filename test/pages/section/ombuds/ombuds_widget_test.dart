import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tv/controller/ombuds_controller.dart';
import 'package:tv/controller/text_scale_factor_controller.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/content.dart';
import 'package:tv/models/paragraph.dart';
import 'package:tv/models/story.dart';
import 'package:tv/models/video.dart';
import 'package:tv/pages/section/ombuds/ombuds_widget.dart';
import 'package:tv/services/ombuds_title_service.dart';
import 'package:tv/services/storyService.dart';
import 'package:tv/services/videoService.dart';

class _StoryServices extends StoryServices {
  @override
  Future<Story> fetchPublishedStoryBySlug(String slug) async {
    expect(slug, 'biography');
    return Story(
      name: '關於鏡電視公評人',
      brief: [
        Paragraph(
          type: 'unstyled',
          contents: [
            Content(data: '後台公評人介紹', aspectRatio: null, description: null),
          ],
        ),
      ],
    );
  }
}

class _VideoServices extends VideoServices {
  @override
  Future<Video> fetchVideoByName(String name) async {
    throw StateError('No video');
  }
}

void main() {
  setUp(() {
    Get.testMode = true;
    Environment().initConfig(BuildFlavor.production);
    SharedPreferences.setMockInitialValues({});
    Get.put(TextScaleFactorController());
  });

  tearDown(() => Get.reset());

  testWidgets(
    'updates the heading from the website without delaying the brief',
    (tester) async {
      final response = Completer<http.Response>();
      final client = MockClient((_) => response.future);
      addTearDown(client.close);
      Get.put(
        OmbudsController(
          storyService: _StoryServices(),
          videoService: _VideoServices(),
          titleService: OmbudsTitleService(client: client),
        ),
      );

      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: OmbudsWidget())),
      );
      await tester.pumpAndSettle();

      expect(find.text('外部公評人莊豐嘉'), findsOneWidget);
      expect(find.text('後台公評人介紹'), findsOneWidget);
      expect(find.text('關於鏡電視公評人'), findsNothing);

      response.complete(
        http.Response.bytes(utf8.encode('<h1>外部公評人新任公評人</h1>'), 200),
      );
      await tester.pumpAndSettle();

      expect(find.text('外部公評人新任公評人'), findsOneWidget);
      expect(find.text('外部公評人莊豐嘉'), findsNothing);
      expect(find.text('後台公評人介紹'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
