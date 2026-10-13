import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tv/controller/ombuds_controller.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/story.dart';
import 'package:tv/models/video.dart';
import 'package:tv/services/ombuds_title_service.dart';
import 'package:tv/services/storyService.dart';
import 'package:tv/services/videoService.dart';

class _StoryServices extends StoryServices {
  _StoryServices(this.fetch);

  final Future<Story> Function() fetch;

  @override
  Future<Story> fetchPublishedStoryBySlug(String slug) {
    expect(slug, 'biography');
    return fetch();
  }
}

class _VideoServices extends VideoServices {
  _VideoServices(this.result);

  final Video result;
  int requests = 0;

  @override
  Future<Video> fetchVideoByName(String name) async {
    expect(name, 'ombuds_office_main_video');
    requests++;
    return result;
  }
}

class _TitleService extends OmbudsTitleService {
  _TitleService(this.fetch);

  final Future<String?> Function() fetch;

  @override
  Future<String?> fetchTitle() => fetch();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Environment().initConfig(BuildFlavor.production);
  });

  tearDown(() {
    Get.reset();
  });

  final biography = Story(name: '公評人介紹', externalContentHtml: '<p>介紹</p>');
  final officeVideo = Video(url: 'https://example.com/ombuds.mp4');

  OmbudsController controllerFor(
    Future<String?> Function() fetchTitle, {
    Future<Story> Function()? fetchStory,
    _VideoServices? videos,
  }) {
    final controller = OmbudsController(
      storyService: _StoryServices(fetchStory ?? () async => biography),
      videoService: videos ?? _VideoServices(officeVideo),
      titleService: _TitleService(fetchTitle),
    );
    addTearDown(controller.onDelete);
    return controller;
  }

  test('updates the title while the biography is still loading', () async {
    final storyResponse = Completer<Story>();
    final titleResponse = Completer<String?>();
    final videos = _VideoServices(officeVideo);
    final controller = controllerFor(
      () => titleResponse.future,
      fetchStory: () => storyResponse.future,
      videos: videos,
    );
    expect(controller.title.value, OmbudsController.fallbackTitle);

    final loading = controller.loadOmbuds();
    titleResponse.complete('外部公評人陳新任');
    await Future<void>.delayed(Duration.zero);

    expect(controller.title.value, '外部公評人陳新任');
    expect(controller.isLoading.value, isTrue);
    expect(controller.story.value, isNull);
    expect(videos.requests, 0);

    storyResponse.complete(biography);
    await loading;
    expect(controller.story.value, same(biography));
    expect(controller.video.value, same(officeVideo));
    expect(controller.isLoading.value, isFalse);
  });

  test('a slow title request does not block biography or video', () async {
    final titleResponse = Completer<String?>();
    final controller = controllerFor(() => titleResponse.future);

    await controller.loadOmbuds().timeout(const Duration(seconds: 1));

    expect(controller.story.value, same(biography));
    expect(controller.video.value, same(officeVideo));
    expect(controller.isLoading.value, isFalse);
    expect(controller.error.value, isNull);
    expect(controller.title.value, OmbudsController.fallbackTitle);

    titleResponse.complete('外部公評人陳新任');
    await Future<void>.delayed(Duration.zero);
    expect(controller.title.value, '外部公評人陳新任');
  });

  for (final failure in [false, true]) {
    test(
      'keeps fallback when the initial title ${failure ? 'fails' : 'is missing'}',
      () async {
        final controller = controllerFor(
          () async => failure ? throw StateError('offline') : null,
        );

        await controller.loadOmbuds();

        expect(controller.title.value, OmbudsController.fallbackTitle);
        expect(controller.story.value, same(biography));
        expect(controller.video.value, same(officeVideo));
        expect(controller.isLoading.value, isFalse);
        expect(controller.error.value, isNull);
      },
    );

    test(
      'retains a fetched title when a refresh ${failure ? 'fails' : 'is missing'}',
      () async {
        var requests = 0;
        final controller = controllerFor(() async {
          if (++requests == 1) return '外部公評人陳新任';
          if (failure) throw StateError('offline');
          return null;
        });

        await controller.loadOmbuds();
        expect(controller.title.value, '外部公評人陳新任');
        await controller.loadOmbuds();

        expect(controller.title.value, '外部公評人陳新任');
        expect(controller.error.value, isNull);
      },
    );
  }

  test('a late previous request cannot overwrite the latest title', () async {
    final first = Completer<String?>();
    final latest = Completer<String?>();
    var requests = 0;
    final controller = controllerFor(
      () => ++requests == 1 ? first.future : latest.future,
    );

    await controller.loadOmbuds();
    await controller.loadOmbuds();
    latest.complete('外部公評人陳新任');
    await Future<void>.delayed(Duration.zero);
    first.complete('外部公評人舊姓名');
    await Future<void>.delayed(Duration.zero);

    expect(controller.title.value, '外部公評人陳新任');
  });

  test('ignores a title response after the controller closes', () async {
    final response = Completer<String?>();
    final controller = controllerFor(() => response.future);

    await controller.loadOmbuds();
    controller.onDelete();
    response.complete('外部公評人陳新任');
    await Future<void>.delayed(Duration.zero);

    expect(controller.isClosed, isTrue);
    expect(controller.title.value, OmbudsController.fallbackTitle);
  });
}
