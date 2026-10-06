import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tv/controller/show_category_controller.dart';
import 'package:tv/controller/text_scale_factor_controller.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/category.dart';
import 'package:tv/models/showIntro.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:tv/pages/section/show/show_category_tab.dart';
import 'package:tv/services/showService.dart';
import 'package:tv/services/youtubePlaylistService.dart';

class _ShowServices extends ShowServices {
  _ShowServices(this.category, this.intro);

  final Category category;
  final ShowIntro intro;

  @override
  Future<List<Category>> fetchCategoryList() async => [category];

  @override
  Future<ShowIntro> fetchShowIntroById(String id) async {
    expect(id, category.id);
    return intro;
  }
}

class _PlaylistServices extends YoutubePlaylistServices {
  final List<String> requestedIds = [];

  @override
  Future<List<YoutubePlaylistItem>> fetchSnippetByPlaylistId(
    String playlistId, {
    int maxResults = 5,
  }) async {
    requestedIds.add(playlistId);
    return [
      YoutubePlaylistItem(
        youtubeVideoId: playlistId,
        name: 'Video from $playlistId',
        photoUrl: 'https://example.com/thumbnail.png',
        publishedAt: null,
      ),
    ];
  }

  @override
  Future<List<YoutubePlaylistItem>> fetchSnippetByPlaylistIdAndPageToken(
    String playlistId, {
    int maxResults = 5,
  }) async => [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  setUp(() {
    Get.testMode = true;
    Environment().initConfig(BuildFlavor.development);
    SharedPreferences.setMockInitialValues({});
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/firebase_analytics'),
      (_) async => null,
    );
    messenger.setMockMessageHandler(
      'plugins.flutter.io/google_mobile_ads',
      (_) async => const StandardMethodCodec().encodeSuccessEnvelope(null),
    );
    Get.put(TextScaleFactorController());
  });

  tearDown(() {
    Get.reset();
  });

  Future<_PlaylistServices> openShow(
    WidgetTester tester, {
    required String slug,
    bool twoPlaylists = false,
  }) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final category = Category(id: 'show-id', name: 'Test show', slug: slug);
    final intro = ShowIntro.fromJson({
      'name': category.name,
      'introduction': 'Show introduction',
      'picture': {'imageApiData': 'https://example.com/show.png'},
      'playList01':
          'https://www.youtube.com/playlist?list=PLfirst：Full episodes',
      'playList02':
          twoPlaylists
              ? 'https://www.youtube.com/playlist?list=PLsecond：Highlights'
              : null,
    });
    final shows = _ShowServices(category, intro);
    final playlists = _PlaylistServices();
    Get.put<ShowServices>(shows);
    Get.put(ShowCategoryController(showService: shows));
    for (final tag in [
      'PLfirst_playlist_single',
      'PLfirst_playlist_01',
      'PLsecond_playlist_02',
    ]) {
      Get.put<YoutubePlaylistServices>(playlists, tag: tag);
    }
    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: ShowCategoryTab())),
    );
    await tester.pumpAndSettle();
    return playlists;
  }

  for (final slug in ['regular-show', 'election-show']) {
    testWidgets('$slug with one playlist has no playlist buttons', (
      tester,
    ) async {
      final playlists = await openShow(tester, slug: slug);

      expect(find.byType(CupertinoSegmentedControl<int>), findsNothing);
      expect(find.text('Full episodes'), findsNothing);
      expect(find.text('Video from PLfirst'), findsOneWidget);
      expect(playlists.requestedIds, ['PLfirst']);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('two playlists show their names and switch video content', (
    tester,
  ) async {
    final playlists = await openShow(
      tester,
      slug: 'regular-show',
      twoPlaylists: true,
    );

    expect(find.byType(CupertinoSegmentedControl<int>), findsOneWidget);
    expect(find.text('Full episodes'), findsOneWidget);
    expect(find.text('Highlights'), findsOneWidget);
    expect(find.text('Video from PLfirst'), findsOneWidget);
    expect(find.text('Video from PLsecond'), findsNothing);

    await tester.tap(find.text('Highlights'));
    await tester.pumpAndSettle();
    expect(find.text('Video from PLsecond'), findsOneWidget);
    expect(find.text('Video from PLfirst'), findsNothing);

    await tester.tap(find.text('Full episodes'));
    await tester.pumpAndSettle();
    expect(find.text('Video from PLfirst'), findsOneWidget);
    expect(find.text('Video from PLsecond'), findsNothing);
    expect(playlists.requestedIds, ['PLfirst', 'PLsecond', 'PLfirst']);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
