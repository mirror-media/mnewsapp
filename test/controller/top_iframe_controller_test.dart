import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tv/controller/top_iframe_controller.dart';

class _TestTopIframeController extends TopIframeController {
  @override
  void initialize({
    Duration refreshInterval = const Duration(minutes: 1),
    bool autoHeight = true,
    double initialHeight = 400,
    bool waitForHeightDetection = false,
  }) {
    // Set up the visible iframe without fetching Remote Config or scheduling
    // automatic refreshes. Firebase Core is initialized with its test mock.
    this.refreshInterval = refreshInterval;
    this.autoHeight = autoHeight;
    this.initialHeight = initialHeight;
    currentUrl.value = 'https://example.com/iframe';
    webViewKey.value = 'active-instance';
    isVisible.value = true;
    currentHeight.value = 200;
  }
}

class _FakeWebViewPlatformController extends PlatformInAppWebViewController {
  _FakeWebViewPlatformController(String id)
    : super.implementation(
        PlatformInAppWebViewControllerCreationParams(id: id),
      );

  final evaluatedSources = <String>[];
  final handlers = <String, JavaScriptHandlerCallback>{};

  @override
  Future<dynamic> evaluateJavascript({
    required String source,
    ContentWorld? contentWorld,
  }) async {
    evaluatedSources.add(source);
    return {'width': 320, 'height': 330};
  }

  @override
  void addJavaScriptHandler({
    required String handlerName,
    required JavaScriptHandlerCallback callback,
  }) {
    handlers[handlerName] = callback;
  }

  @override
  JavaScriptHandlerCallback? removeJavaScriptHandler({
    required String handlerName,
  }) => handlers.remove(handlerName);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  late _TestTopIframeController controller;
  late _FakeWebViewPlatformController platform;
  late InAppWebViewController createdWrapper;

  setUp(() {
    controller = _TestTopIframeController()..onInit();
    platform = _FakeWebViewPlatformController('native-webview');
    createdWrapper = InAppWebViewController.fromPlatform(platform: platform);
    controller.onWebViewCreated(
      createdWrapper,
      instanceKey: controller.webViewKey.value,
    );
  });

  tearDown(() {
    controller.onClose();
  });

  test(
    'load callbacks accept a new Dart wrapper for the same native view',
    () async {
      final callbackWrapper = InAppWebViewController.fromPlatform(
        platform: platform,
      );
      expect(identical(createdWrapper, callbackWrapper), isFalse);

      controller.onLoadStart(
        webController: callbackWrapper,
        instanceKey: controller.webViewKey.value,
      );
      await controller.onLoadStop(
        webController: callbackWrapper,
        instanceKey: controller.webViewKey.value,
      );

      expect(controller.isLoading.value, isFalse);
      expect(controller.loadingTimeoutTimer, isNull);
      expect(controller.hasError.value, isFalse);
      expect(controller.currentWidth.value, 320);
      expect(controller.currentHeight.value, 330);
      expect(controller.hasDetectedHeight.value, isTrue);
      expect(platform.evaluatedSources, isNotEmpty);
    },
  );

  test(
    'load stop ignores another platform controller with the same native id',
    () async {
      final unrelatedPlatform = _FakeWebViewPlatformController(platform.id);
      final unrelatedWrapper = InAppWebViewController.fromPlatform(
        platform: unrelatedPlatform,
      );

      await controller.onLoadStop(
        webController: unrelatedWrapper,
        instanceKey: controller.webViewKey.value,
      );

      expect(controller.isLoading.value, isTrue);
      expect(controller.loadingTimeoutTimer?.isActive, isTrue);
      expect(controller.currentWidth.value, isNull);
      expect(controller.currentHeight.value, 200);
      expect(controller.hasDetectedHeight.value, isFalse);
      expect(unrelatedPlatform.evaluatedSources, isEmpty);
      expect(platform.evaluatedSources, isEmpty);
    },
  );

  test(
    'load stop ignores a stale key even for the current native view',
    () async {
      final callbackWrapper = InAppWebViewController.fromPlatform(
        platform: platform,
      );

      await controller.onLoadStop(
        webController: callbackWrapper,
        instanceKey: 'previous-instance',
      );

      expect(controller.isLoading.value, isTrue);
      expect(controller.loadingTimeoutTimer?.isActive, isTrue);
      expect(controller.currentWidth.value, isNull);
      expect(controller.currentHeight.value, 200);
      expect(controller.hasDetectedHeight.value, isFalse);
      expect(platform.evaluatedSources, isEmpty);
    },
  );
}
