import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tv/widgets/top_iframe_gesture_recognizer.dart';

class _FakePlatformViewController extends PlatformViewController {
  final events = <PointerEvent>[];

  @override
  int get viewId => 0;

  @override
  Future<void> dispatchPointerEvent(PointerEvent event) async {
    events.add(event);
  }

  @override
  Future<void> clearFocus() async {}

  @override
  Future<void> dispose() async {}
}

void main() {
  for (final useUiKit in [false, true]) {
    group(useUiKit ? 'iOS platform view' : 'platform view surface', () {
      late ScrollController scrollController;
      late _FakePlatformViewController platformController;
      late bool dropdownOpen;
      late List<String> nativeGestureDecisions;

      setUp(() {
        dropdownOpen = false;
        scrollController = ScrollController();
        platformController = _FakePlatformViewController();
        nativeGestureDecisions = [];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform_views, (
              call,
            ) async {
              if (call.method == 'acceptGesture' ||
                  call.method == 'rejectGesture') {
                nativeGestureDecisions.add(call.method);
              }
              return null;
            });
      });

      tearDown(() {
        scrollController.dispose();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform_views, null);
      });

      Future<void> mount(WidgetTester tester) async {
        final recognizers = <Factory<OneSequenceGestureRecognizer>>{
          Factory<TopIframeVerticalDragGestureRecognizer>(
            () => TopIframeVerticalDragGestureRecognizer(
              isDropdownOpen: () => dropdownOpen,
            )..gestureSettings = const DeviceGestureSettings(touchSlop: 18),
          ),
        };
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              gestureSettings: DeviceGestureSettings(touchSlop: 18),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    SizedBox(
                      width: 320,
                      height: 330,
                      child:
                          useUiKit
                              ? UiKitView(
                                viewType: 'test-webview',
                                gestureRecognizers: recognizers,
                              )
                              : PlatformViewSurface(
                                controller: platformController,
                                hitTestBehavior:
                                    PlatformViewHitTestBehavior.opaque,
                                gestureRecognizers: recognizers,
                              ),
                    ),
                    const SizedBox(height: 1600),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump();
      }

      Future<void> drag(WidgetTester tester, {Offset? from}) async {
        final gesture = await tester.startGesture(
          from ?? const Offset(400, 200),
        );
        await gesture.moveBy(const Offset(0, -40));
        await gesture.moveBy(const Offset(0, -40));
        await gesture.up();
        await tester.pumpAndSettle();
      }

      void expectNativeDrag(bool accepted) {
        if (useUiKit) {
          expect(
            nativeGestureDecisions,
            contains(accepted ? 'acceptGesture' : 'rejectGesture'),
          );
          expect(
            nativeGestureDecisions,
            isNot(contains(accepted ? 'rejectGesture' : 'acceptGesture')),
          );
        } else if (accepted) {
          expect(platformController.events.first, isA<PointerDownEvent>());
          expect(
            platformController.events.whereType<PointerMoveEvent>(),
            isNotEmpty,
          );
          expect(platformController.events.last, isA<PointerUpEvent>());
        } else {
          expect(platformController.events, isEmpty);
        }
      }

      testWidgets('closed dropdown lets the homepage scroll', (tester) async {
        await mount(tester);
        await drag(tester);
        expect(scrollController.offset, greaterThan(0));
        expectNativeDrag(false);
      });

      testWidgets(
        'open dropdown receives drag without scrolling the homepage',
        (tester) async {
          await mount(tester);
          dropdownOpen = true;
          await drag(tester);
          expect(scrollController.offset, 0);
          expectNativeDrag(true);

          // Close without rebuilding or replacing the platform view/recognizer.
          dropdownOpen = false;
          await drag(tester);
          expect(scrollController.offset, greaterThan(0));
        },
      );

      testWidgets('outside the WebView still scrolls with a dropdown open', (
        tester,
      ) async {
        await mount(tester);
        dropdownOpen = true;
        await drag(tester, from: const Offset(400, 450));
        expect(scrollController.offset, greaterThan(0));
        expect(platformController.events, isEmpty);
        expect(nativeGestureDecisions, isEmpty);
      });

      for (final openAtDown in [false, true]) {
        testWidgets(
          'state changes after pointer-down preserve gesture ownership ($openAtDown)',
          (tester) async {
            await mount(tester);
            dropdownOpen = openAtDown;
            final gesture = await tester.startGesture(const Offset(400, 200));
            dropdownOpen = !openAtDown;
            await gesture.moveBy(const Offset(0, -40));
            await gesture.moveBy(const Offset(0, -40));
            await gesture.up();
            await tester.pumpAndSettle();
            expect(scrollController.offset, openAtDown ? 0 : greaterThan(0));
            expectNativeDrag(openAtDown);
          },
        );
      }

      testWidgets('tap can open a dropdown without cancelling native input', (
        tester,
      ) async {
        await mount(tester);
        final gesture = await tester.startGesture(const Offset(400, 200));
        dropdownOpen = true;
        await gesture.up();
        await tester.pump();
        expect(scrollController.offset, 0);
        if (useUiKit) {
          expect(nativeGestureDecisions, ['acceptGesture']);
        } else {
          expect(platformController.events, [
            isA<PointerDownEvent>(),
            isA<PointerUpEvent>(),
          ]);
        }
      });
    });
  }
}
