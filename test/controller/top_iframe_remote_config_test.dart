import 'dart:async';
import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_remote_config_platform_interface/firebase_remote_config_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tv/controller/top_iframe_controller.dart';

class _LocalRemoteConfigPlatform extends FirebaseRemoteConfigPlatform {
  final remoteValues = <String, dynamic>{};
  final updates = StreamController<RemoteConfigUpdate>.broadcast(sync: true);
  bool failFetch = false;
  int fetchCalls = 0;
  int activateCalls = 0;

  void reset() {
    remoteValues.clear();
    failFetch = false;
    fetchCalls = 0;
    activateCalls = 0;
  }

  @override
  FirebaseRemoteConfigPlatform delegateFor({required FirebaseApp app}) => this;

  @override
  FirebaseRemoteConfigPlatform setInitialValues({
    required Map<dynamic, dynamic> remoteConfigValues,
  }) => this;

  @override
  RemoteConfigValue getValue(String key) {
    if (remoteValues.containsKey(key)) {
      return _LocalConfigValue(remoteValues[key], ValueSource.valueRemote);
    }
    return _LocalConfigValue(null, ValueSource.valueStatic);
  }

  @override
  bool getBool(String key) => getValue(key).asBool();

  @override
  String getString(String key) => getValue(key).asString();

  @override
  Future<void> setConfigSettings(RemoteConfigSettings settings) async {}

  @override
  Future<void> fetch() async {
    fetchCalls++;
    if (failFetch) throw StateError('Offline test device');
  }

  @override
  Future<bool> activate() async {
    activateCalls++;
    return true;
  }

  @override
  Stream<RemoteConfigUpdate> get onConfigUpdated => updates.stream;
}

class _LocalConfigValue extends RemoteConfigValue {
  _LocalConfigValue(Object? value, ValueSource source)
    : super(value == null ? null : utf8.encode(value.toString()), source);
}

class _LocalTopIframeController extends TopIframeController {
  _LocalTopIframeController({super.now});

  @override
  void initialize({
    Duration refreshInterval = const Duration(minutes: 1),
    bool autoHeight = true,
    double initialHeight = 400,
    bool waitForHeightDetection = false,
  }) {
    // Exercise production checkVisibility without fetching or polling Firebase.
    this.refreshInterval = refreshInterval;
    this.autoHeight = autoHeight;
    this.initialHeight = initialHeight;
    currentHeight.value = autoHeight ? 200 : initialHeight;
    webViewKey.value = 'before-remote-config';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  const iframeUrl = 'https://example.com/iframe';
  final scheduleNow = DateTime.utc(2026, 11, 1);
  late FirebaseRemoteConfigPlatform originalPlatform;
  late _LocalRemoteConfigPlatform platform;
  late FirebaseRemoteConfig remoteConfig;
  late TopIframeController controller;

  setUpAll(() async {
    await Firebase.initializeApp();
    originalPlatform = FirebaseRemoteConfigPlatform.instance;
    platform = _LocalRemoteConfigPlatform();
    FirebaseRemoteConfigPlatform.instance = platform;
    // FirebaseRemoteConfig caches its delegate, so retain this platform across
    // cases and clear only its values. All data stays in this test process.
    remoteConfig = FirebaseRemoteConfig.instance;
  });

  setUp(() {
    platform.reset();
    controller = _LocalTopIframeController()..onInit();
  });

  tearDown(() {
    controller.onClose();
  });

  tearDownAll(() async {
    await platform.updates.close();
    FirebaseRemoteConfigPlatform.instance = originalPlatform;
  });

  void applyRemoteValues(Map<String, dynamic> values) {
    platform.remoteValues
      ..clear()
      ..addAll(values);
    controller.checkVisibility();
  }

  void replaceController(
    DateTime Function() now, {
    bool fullInitialization = false,
  }) {
    controller.onClose();
    controller =
        fullInitialization
            ? TopIframeController(now: now)
            : _LocalTopIframeController(now: now);
    controller.onInit();
  }

  test(
    'SDK empty values keep an unconfigured iframe and optional controls hidden',
    () {
      controller.checkVisibility();

      expect(remoteConfig.getBool('homepageEmbedEnabled'), isFalse);
      for (final key in [
        'homepageEmbedUrl',
        'homepageEmbedTitle',
        'homepageEmbedShowMoreUrl',
      ]) {
        expect(remoteConfig.getString(key), isEmpty);
        expect(remoteConfig.getValue(key).source, ValueSource.valueStatic);
      }
      expect(
        remoteConfig.getValue('homepageEmbedEnabled').source,
        ValueSource.valueStatic,
      );
      expect(controller.isVisible.value, isFalse);
      expect(controller.currentUrl.value, isNull);
      expect(controller.currentWidth.value, isNull);
      expect(controller.title.value, isNull);
      expect(controller.showMoreUrl.value, isNull);
    },
  );

  test('remote enable and URL display the iframe and optional values', () {
    applyRemoteValues({
      'homepageEmbedEnabled': true,
      'homepageEmbedUrl': iframeUrl,
      'homepageEmbedTitle': '選舉即時資訊',
      'homepageEmbedShowMoreUrl': 'https://example.com/more',
    });

    expect(controller.isVisible.value, isTrue);
    expect(controller.currentUrl.value, iframeUrl);
    expect(controller.title.value, '選舉即時資訊');
    expect(controller.showMoreUrl.value, 'https://example.com/more');
    expect(controller.isLoading.value, isTrue);
  });

  test('remote disable removes an already displayed iframe and its width', () {
    applyRemoteValues({
      'homepageEmbedEnabled': true,
      'homepageEmbedUrl': iframeUrl,
    });
    controller.currentWidth.value = 320;

    applyRemoteValues({
      'homepageEmbedEnabled': false,
      'homepageEmbedUrl': iframeUrl,
    });

    expect(controller.isVisible.value, isFalse);
    expect(controller.currentUrl.value, isNull);
    expect(controller.currentWidth.value, isNull);
    expect(controller.loadingTimeoutTimer, isNull);
  });

  test('an empty URL hides an iframe even when remotely enabled', () {
    applyRemoteValues({
      'homepageEmbedEnabled': true,
      'homepageEmbedUrl': iframeUrl,
    });
    controller.currentWidth.value = 320;

    applyRemoteValues({'homepageEmbedEnabled': true, 'homepageEmbedUrl': ''});

    expect(controller.isVisible.value, isFalse);
    expect(controller.currentUrl.value, isNull);
    expect(controller.currentWidth.value, isNull);
  });

  test(
    'empty optional values remove existing controls and keep the iframe',
    () {
      applyRemoteValues({
        'homepageEmbedEnabled': true,
        'homepageEmbedUrl': iframeUrl,
        'homepageEmbedTitle': '選舉即時資訊',
        'homepageEmbedShowMoreUrl': 'https://example.com/more',
      });

      applyRemoteValues({
        'homepageEmbedEnabled': true,
        'homepageEmbedUrl': iframeUrl,
        'homepageEmbedTitle': '',
        'homepageEmbedShowMoreUrl': '',
      });

      expect(controller.isVisible.value, isTrue);
      expect(controller.currentUrl.value, iframeUrl);
      expect(controller.title.value, isNull);
      expect(controller.showMoreUrl.value, isNull);
    },
  );

  test('changing the URL clears old dimensions, errors and loading state', () {
    applyRemoteValues({
      'homepageEmbedEnabled': true,
      'homepageEmbedUrl': iframeUrl,
    });
    final previousKey = controller.webViewKey.value;
    controller.currentWidth.value = 320;
    controller.currentHeight.value = 330;
    controller.hasDetectedHeight.value = true;
    controller.isLoading.value = false;
    controller.hasError.value = true;
    controller.errorMessage.value = 'Previous page failed';

    applyRemoteValues({
      'homepageEmbedEnabled': true,
      'homepageEmbedUrl': 'https://example.com/another-iframe',
    });

    expect(controller.isVisible.value, isTrue);
    expect(controller.currentUrl.value, 'https://example.com/another-iframe');
    expect(controller.webViewKey.value, isNot(previousKey));
    expect(controller.currentWidth.value, isNull);
    expect(controller.currentHeight.value, 200);
    expect(controller.hasDetectedHeight.value, isFalse);
    expect(controller.isLoading.value, isTrue);
    expect(controller.hasError.value, isFalse);
    expect(controller.errorMessage.value, isNull);
  });

  test(
    'optional field changes keep the same URL, native instance and dimensions',
    () {
      applyRemoteValues({
        'homepageEmbedEnabled': true,
        'homepageEmbedUrl': iframeUrl,
      });
      final previousKey = controller.webViewKey.value;
      controller.currentWidth.value = 320;
      controller.currentHeight.value = 330;
      controller.hasDetectedHeight.value = true;
      controller.isLoading.value = false;

      applyRemoteValues({
        'homepageEmbedEnabled': true,
        'homepageEmbedUrl': iframeUrl,
        'homepageEmbedTitle': '新標題',
        'homepageEmbedShowMoreUrl': 'https://example.com/more',
      });

      expect(controller.title.value, '新標題');
      expect(controller.showMoreUrl.value, 'https://example.com/more');
      expect(controller.webViewKey.value, previousKey);
      expect(controller.currentWidth.value, 320);
      expect(controller.currentHeight.value, 330);
      expect(controller.hasDetectedHeight.value, isTrue);
      expect(controller.isLoading.value, isFalse);
    },
  );

  test(
    'empty schedule fields preserve the original manual display behavior',
    () {
      applyRemoteValues({
        'homepageEmbedEnabled': true,
        'homepageEmbedUrl': iframeUrl,
        'homepageEmbedStartAt': '',
        'homepageEmbedEndAt': '',
      });

      expect(controller.isVisible.value, isTrue);
      expect(controller.currentUrl.value, iframeUrl);
      expect(controller.scheduleTimer, isNull);
    },
  );

  test(
    'cached schedule opens at start and closes at end while fetch is offline',
    () {
      fakeAsync((async) {
        platform.failFetch = true;
        platform.remoteValues.addAll({
          'homepageEmbedEnabled': true,
          'homepageEmbedUrl': iframeUrl,
          'homepageEmbedStartAt':
              scheduleNow.add(const Duration(seconds: 10)).toIso8601String(),
          'homepageEmbedEndAt':
              scheduleNow.add(const Duration(seconds: 20)).toIso8601String(),
        });
        replaceController(
          () => scheduleNow.add(async.elapsed),
          fullInitialization: true,
        );
        async.flushMicrotasks();

        expect(controller.isVisible.value, isFalse);
        expect(controller.scheduleTimer?.isActive, isTrue);
        expect(platform.fetchCalls, 1);
        expect(platform.activateCalls, 0);

        async.elapse(const Duration(milliseconds: 9999));
        expect(controller.isVisible.value, isFalse);
        async.elapse(const Duration(milliseconds: 1));
        expect(controller.isVisible.value, isTrue);
        expect(controller.currentUrl.value, iframeUrl);
        controller.currentWidth.value = 320;

        async.elapse(const Duration(milliseconds: 9999));
        expect(controller.isVisible.value, isTrue);
        async.elapse(const Duration(milliseconds: 1));
        expect(controller.isVisible.value, isFalse);
        expect(controller.currentUrl.value, isNull);
        expect(controller.currentWidth.value, isNull);
        expect(controller.scheduleTimer, isNull);
        expect(platform.fetchCalls, 1);
      });
    },
  );

  test(
    'editing schedule cancels old timers without reloading an active URL',
    () {
      fakeAsync((async) {
        replaceController(() => scheduleNow.add(async.elapsed));
        applyRemoteValues({
          'homepageEmbedEnabled': true,
          'homepageEmbedUrl': iframeUrl,
          'homepageEmbedStartAt':
              scheduleNow.add(const Duration(minutes: 1)).toIso8601String(),
          'homepageEmbedEndAt':
              scheduleNow.add(const Duration(minutes: 2)).toIso8601String(),
        });
        final futureStartTimer = controller.scheduleTimer!;

        applyRemoteValues({
          'homepageEmbedEnabled': true,
          'homepageEmbedUrl': iframeUrl,
          'homepageEmbedStartAt':
              scheduleNow
                  .subtract(const Duration(minutes: 1))
                  .toIso8601String(),
          'homepageEmbedEndAt':
              scheduleNow.add(const Duration(seconds: 10)).toIso8601String(),
        });
        expect(futureStartTimer.isActive, isFalse);
        expect(controller.isVisible.value, isTrue);
        final previousKey = controller.webViewKey.value;
        final oldEndTimer = controller.scheduleTimer!;
        controller.currentWidth.value = 320;
        controller.currentHeight.value = 330;
        controller.isLoading.value = false;

        platform.remoteValues['homepageEmbedEndAt'] =
            scheduleNow.add(const Duration(seconds: 20)).toIso8601String();
        controller.checkVisibility();

        expect(oldEndTimer.isActive, isFalse);
        expect(controller.webViewKey.value, previousKey);
        expect(controller.currentWidth.value, 320);
        expect(controller.currentHeight.value, 330);
        expect(controller.isLoading.value, isFalse);
        async.elapse(const Duration(seconds: 10));
        expect(controller.isVisible.value, isTrue);
        async.elapse(const Duration(seconds: 10));
        expect(controller.isVisible.value, isFalse);
        expect(controller.scheduleTimer, isNull);
      });
    },
  );

  test(
    'invalid schedules hide an active iframe and cancel its next boundary',
    () {
      replaceController(() => scheduleNow);
      final validEnd =
          scheduleNow.add(const Duration(minutes: 1)).toIso8601String();
      final invalidSchedules = [
        {'start': '2026-11-01T00:00:00', 'end': validEnd},
        {'start': '2026-02-30T00:00:00Z', 'end': validEnd},
        {'start': validEnd, 'end': scheduleNow.toIso8601String()},
        {'start': validEnd, 'end': validEnd},
      ];

      for (final schedule in invalidSchedules) {
        applyRemoteValues({
          'homepageEmbedEnabled': true,
          'homepageEmbedUrl': iframeUrl,
          'homepageEmbedEndAt': validEnd,
        });
        expect(controller.isVisible.value, isTrue);
        final previousTimer = controller.scheduleTimer!;
        controller.currentWidth.value = 320;

        applyRemoteValues({
          'homepageEmbedEnabled': true,
          'homepageEmbedUrl': iframeUrl,
          'homepageEmbedStartAt': schedule['start'],
          'homepageEmbedEndAt': schedule['end'],
        });

        expect(controller.isVisible.value, isFalse, reason: '$schedule');
        expect(controller.currentWidth.value, isNull, reason: '$schedule');
        expect(previousTimer.isActive, isFalse, reason: '$schedule');
        expect(controller.scheduleTimer, isNull, reason: '$schedule');
      }
    },
  );

  test(
    'the homepage embed master switch overrides an otherwise active schedule',
    () {
      fakeAsync((async) {
        replaceController(() => scheduleNow.add(async.elapsed));
        applyRemoteValues({
          'homepageEmbedEnabled': true,
          'homepageEmbedUrl': iframeUrl,
          'homepageEmbedEndAt':
              scheduleNow.add(const Duration(seconds: 10)).toIso8601String(),
        });
        final previousTimer = controller.scheduleTimer!;
        expect(controller.isVisible.value, isTrue);

        platform.remoteValues['homepageEmbedEnabled'] = false;
        controller.checkVisibility();

        expect(controller.isVisible.value, isFalse);
        expect(controller.scheduleTimer, isNull);
        expect(previousTimer.isActive, isFalse);
        async.elapse(const Duration(seconds: 20));
        expect(controller.isVisible.value, isFalse);
      });
    },
  );

  test(
    'resuming applies an expired cached schedule before a failed refresh',
    () {
      fakeAsync((async) {
        var now = scheduleNow;
        platform.failFetch = true;
        platform.remoteValues.addAll({
          'homepageEmbedEnabled': true,
          'homepageEmbedUrl': iframeUrl,
          'homepageEmbedEndAt':
              now.add(const Duration(seconds: 10)).toIso8601String(),
        });
        replaceController(() => now, fullInitialization: true);
        async.flushMicrotasks();
        expect(controller.isVisible.value, isTrue);
        controller.currentWidth.value = 320;
        final previousTimer = controller.scheduleTimer!;

        // Advance the device clock without running timers, as while suspended.
        now = now.add(const Duration(seconds: 20));
        controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
        expect(controller.isVisible.value, isFalse);
        expect(controller.currentWidth.value, isNull);
        expect(previousTimer.isActive, isFalse);
        expect(controller.scheduleTimer, isNull);
        async.flushMicrotasks();
        expect(platform.fetchCalls, 2);
      });
    },
  );

  test(
    'real-time schedule updates activate and reschedule until controller closes',
    () {
      fakeAsync((async) {
        platform.remoteValues.addAll({
          'homepageEmbedEnabled': true,
          'homepageEmbedUrl': iframeUrl,
          'homepageEmbedStartAt':
              scheduleNow.add(const Duration(minutes: 1)).toIso8601String(),
          'homepageEmbedEndAt':
              scheduleNow.add(const Duration(minutes: 2)).toIso8601String(),
        });
        replaceController(() => scheduleNow, fullInitialization: true);
        async.flushMicrotasks();
        expect(controller.isVisible.value, isFalse);
        expect(platform.updates.hasListener, isTrue);
        final previousTimer = controller.scheduleTimer!;
        final fetchCallsBeforeUpdate = platform.fetchCalls;
        final activateCallsBeforeUpdate = platform.activateCalls;

        platform.remoteValues['homepageEmbedStartAt'] =
            scheduleNow.subtract(const Duration(minutes: 1)).toIso8601String();
        platform.updates.add(RemoteConfigUpdate({'homepageEmbedStartAt'}));
        async.flushMicrotasks();

        expect(controller.isVisible.value, isTrue);
        expect(previousTimer.isActive, isFalse);
        expect(controller.scheduleTimer?.isActive, isTrue);
        expect(platform.activateCalls, activateCallsBeforeUpdate + 1);
        expect(platform.fetchCalls, fetchCallsBeforeUpdate);

        final activeTimer = controller.scheduleTimer!;
        controller.onClose();
        async.flushMicrotasks();
        expect(activeTimer.isActive, isFalse);
        expect(controller.scheduleTimer, isNull);
        expect(platform.updates.hasListener, isFalse);
        platform.updates.add(RemoteConfigUpdate({'homepageEmbedStartAt'}));
        async.flushMicrotasks();
        expect(platform.activateCalls, activateCallsBeforeUpdate + 1);
      });
    },
  );

  test(
    'legacy enabled, URL, controls and schedule cannot enable the homepage embed',
    () {
      replaceController(() => scheduleNow);
      for (final embedUrlValues in [
        <String, dynamic>{},
        {'homepageEmbedUrl': iframeUrl},
      ]) {
        applyRemoteValues({
          'isTopIframeShow': true,
          'topIframeUrl': 'https://example.com/legacy-iframe',
          'iframeTitle': '舊版標題',
          'iframeShowMoreUrl': 'https://example.com/legacy-more',
          'topIframeStartAt':
              scheduleNow
                  .subtract(const Duration(minutes: 1))
                  .toIso8601String(),
          'topIframeEndAt':
              scheduleNow.add(const Duration(minutes: 1)).toIso8601String(),
          ...embedUrlValues,
        });

        expect(controller.isVisible.value, isFalse, reason: '$embedUrlValues');
        expect(controller.currentUrl.value, isNull, reason: '$embedUrlValues');
        expect(controller.title.value, isNull, reason: '$embedUrlValues');
        expect(controller.showMoreUrl.value, isNull, reason: '$embedUrlValues');
        expect(controller.scheduleTimer, isNull, reason: '$embedUrlValues');
      }
    },
  );

  test(
    'a disabled homepage embed takes priority over legacy enabled and a valid URL',
    () {
      replaceController(() => scheduleNow);
      applyRemoteValues({
        'isTopIframeShow': true,
        'topIframeUrl': 'https://example.com/legacy-iframe',
        'homepageEmbedEnabled': false,
        'homepageEmbedUrl': iframeUrl,
        'homepageEmbedEndAt':
            scheduleNow.add(const Duration(minutes: 1)).toIso8601String(),
      });

      expect(controller.isVisible.value, isFalse);
      expect(controller.currentUrl.value, isNull);
      expect(controller.scheduleTimer, isNull);
    },
  );

  test(
    'homepage embed values display independently of conflicting legacy values',
    () {
      replaceController(() => scheduleNow);
      applyRemoteValues({
        'isTopIframeShow': false,
        'topIframeUrl': 'https://example.com/legacy-iframe',
        'iframeTitle': '舊版標題',
        'iframeShowMoreUrl': 'https://example.com/legacy-more',
        'topIframeStartAt':
            scheduleNow.add(const Duration(days: 1)).toIso8601String(),
        'topIframeEndAt':
            scheduleNow.add(const Duration(days: 2)).toIso8601String(),
        'homepageEmbedEnabled': true,
        'homepageEmbedUrl': iframeUrl,
        'homepageEmbedTitle': '新版標題',
        'homepageEmbedShowMoreUrl': 'https://example.com/homepage-more',
        'homepageEmbedStartAt':
            scheduleNow.subtract(const Duration(minutes: 1)).toIso8601String(),
        'homepageEmbedEndAt':
            scheduleNow.add(const Duration(minutes: 1)).toIso8601String(),
      });

      expect(controller.isVisible.value, isTrue);
      expect(controller.currentUrl.value, iframeUrl);
      expect(controller.title.value, '新版標題');
      expect(controller.showMoreUrl.value, 'https://example.com/homepage-more');
      expect(controller.scheduleTimer?.isActive, isTrue);
    },
  );

  test(
    'missing or empty homepage embed URL never falls back to the legacy URL',
    () {
      for (final embedUrlValues in [
        <String, dynamic>{},
        {'homepageEmbedUrl': ''},
      ]) {
        applyRemoteValues({
          'isTopIframeShow': true,
          'topIframeUrl': 'https://example.com/legacy-iframe',
          'homepageEmbedEnabled': true,
          ...embedUrlValues,
        });

        expect(controller.isVisible.value, isFalse, reason: '$embedUrlValues');
        expect(controller.currentUrl.value, isNull, reason: '$embedUrlValues');
        expect(controller.scheduleTimer, isNull, reason: '$embedUrlValues');
      }
    },
  );

  test(
    'legacy controls and times never fill missing or empty homepage embed fields',
    () {
      replaceController(() => scheduleNow);
      for (final embedOptionalValues in [
        <String, dynamic>{},
        {
          'homepageEmbedTitle': '',
          'homepageEmbedShowMoreUrl': '',
          'homepageEmbedStartAt': '',
          'homepageEmbedEndAt': '',
        },
      ]) {
        applyRemoteValues({
          'homepageEmbedEnabled': true,
          'homepageEmbedUrl': iframeUrl,
          'iframeTitle': '舊版標題',
          'iframeShowMoreUrl': 'https://example.com/legacy-more',
          // Either legacy boundary would hide the homepage embed if it were used as fallback.
          'topIframeStartAt':
              scheduleNow.add(const Duration(days: 1)).toIso8601String(),
          'topIframeEndAt':
              scheduleNow.subtract(const Duration(days: 1)).toIso8601String(),
          ...embedOptionalValues,
        });

        expect(
          controller.isVisible.value,
          isTrue,
          reason: '$embedOptionalValues',
        );
        expect(controller.currentUrl.value, iframeUrl);
        expect(controller.title.value, isNull, reason: '$embedOptionalValues');
        expect(
          controller.showMoreUrl.value,
          isNull,
          reason: '$embedOptionalValues',
        );
        expect(
          controller.scheduleTimer,
          isNull,
          reason: '$embedOptionalValues',
        );
      }
    },
  );

  test(
    'legacy real-time keys are ignored while homepage embed schedule updates still apply',
    () {
      fakeAsync((async) {
        platform.remoteValues.addAll({
          'homepageEmbedEnabled': true,
          'homepageEmbedUrl': iframeUrl,
          'homepageEmbedStartAt':
              scheduleNow.add(const Duration(minutes: 1)).toIso8601String(),
          'homepageEmbedEndAt':
              scheduleNow.add(const Duration(minutes: 2)).toIso8601String(),
        });
        replaceController(() => scheduleNow, fullInitialization: true);
        async.flushMicrotasks();
        final previousTimer = controller.scheduleTimer!;
        final fetchCallsBeforeUpdate = platform.fetchCalls;
        final activateCallsBeforeUpdate = platform.activateCalls;

        platform.remoteValues.addAll({
          'isTopIframeShow': true,
          'topIframeUrl': 'https://example.com/legacy-iframe',
          'iframeTitle': '舊版標題',
          'iframeShowMoreUrl': 'https://example.com/legacy-more',
          'topIframeStartAt':
              scheduleNow.subtract(const Duration(days: 1)).toIso8601String(),
          'topIframeEndAt':
              scheduleNow.add(const Duration(days: 1)).toIso8601String(),
        });
        for (final legacyKey in [
          'isTopIframeShow',
          'topIframeUrl',
          'iframeTitle',
          'iframeShowMoreUrl',
          'topIframeStartAt',
          'topIframeEndAt',
        ]) {
          platform.updates.add(RemoteConfigUpdate({legacyKey}));
          async.flushMicrotasks();

          expect(
            platform.activateCalls,
            activateCallsBeforeUpdate,
            reason: legacyKey,
          );
          expect(
            platform.fetchCalls,
            fetchCallsBeforeUpdate,
            reason: legacyKey,
          );
          expect(
            identical(controller.scheduleTimer, previousTimer),
            isTrue,
            reason: legacyKey,
          );
          expect(previousTimer.isActive, isTrue, reason: legacyKey);
          expect(controller.isVisible.value, isFalse, reason: legacyKey);
          expect(controller.title.value, isNull, reason: legacyKey);
          expect(controller.showMoreUrl.value, isNull, reason: legacyKey);
        }

        platform.remoteValues['homepageEmbedStartAt'] =
            scheduleNow.subtract(const Duration(minutes: 1)).toIso8601String();
        platform.updates.add(RemoteConfigUpdate({'homepageEmbedStartAt'}));
        async.flushMicrotasks();

        expect(platform.activateCalls, activateCallsBeforeUpdate + 1);
        expect(platform.fetchCalls, fetchCallsBeforeUpdate);
        expect(previousTimer.isActive, isFalse);
        expect(controller.isVisible.value, isTrue);
        expect(controller.currentUrl.value, iframeUrl);
        expect(controller.scheduleTimer?.isActive, isTrue);
      });
    },
  );
}
