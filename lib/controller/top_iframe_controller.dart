import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:tv/helpers/top_iframe_helper.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class TopIframeController extends GetxController {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxnString errorMessage = RxnString();
  final RxDouble currentHeight = 400.0.obs;
  final RxnString currentUrl = RxnString();
  final RxnString webViewKey = RxnString();
  final RxBool isVisible = false.obs;
  final RxBool hasDetectedHeight = false.obs;
  final RxnString title = RxnString();
  final RxnString showMoreUrl = RxnString();

  InAppWebViewController? webViewController;
  Timer? refreshTimer;
  Timer? loadingTimeoutTimer;

  late Duration refreshInterval;
  late bool autoHeight;
  late double initialHeight;

  void initialize({
    Duration refreshInterval = const Duration(minutes: 1),
    bool autoHeight = true,
    double initialHeight = 400,
    bool waitForHeightDetection = false,
  }) {
    this.refreshInterval = refreshInterval;
    this.autoHeight = autoHeight;
    this.initialHeight = initialHeight;

    currentHeight.value = autoHeight ? 200 : initialHeight;
    webViewKey.value = TopIframeHelper.generateWebViewKey('');

    _initializeRemoteConfig();
    startAutoRefresh();
  }

  Future<void> _initializeRemoteConfig() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));

      await _remoteConfig.fetch();
      await _remoteConfig.activate();
      checkVisibility();
    } catch (e) {
      // Silently handle errors
    }
  }

  void checkVisibility() {
    bool isShow = _remoteConfig.getBool('isTopIframeShow');
    String url = _remoteConfig.getString('topIframeUrl');
    String titleText = _remoteConfig.getString('iframeTitle');
    String moreUrl = _remoteConfig.getString('iframeShowMoreUrl');

    bool shouldBeVisible = isShow && url.isNotEmpty;

    title.value = titleText.isEmpty ? null : titleText;
    showMoreUrl.value = moreUrl.isEmpty ? null : moreUrl;

    if (shouldBeVisible) {
      if (currentUrl.value != url) {
        currentUrl.value = url;
        isVisible.value = true;
        resetWebViewState();
      } else if (!isVisible.value) {
        isVisible.value = true;
        resetWebViewState();
      }
    } else {
      if (isVisible.value) {
        isVisible.value = false;
        currentUrl.value = null;
        TopIframeHelper.safeDisposeWebView(webViewController);
        webViewController = null;
        _cancelLoadingTimeout();
      }
    }
  }

  Future<void> refreshRemoteConfig() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));

      await _remoteConfig.fetch();
      await _remoteConfig.activate();
      checkVisibility();
    } catch (e) {
      // Silently handle errors
    }
  }

  void resetWebViewState() {
    TopIframeHelper.safeDisposeWebView(webViewController);
    webViewController = null;

    isLoading.value = true;
    hasError.value = false;
    hasDetectedHeight.value = false;
    errorMessage.value = null;

    currentHeight.value = autoHeight ? 200 : initialHeight;
    webViewKey.value =
        TopIframeHelper.generateWebViewKey(currentUrl.value ?? '');

    _cancelLoadingTimeout();
  }

  void startAutoRefresh() {
    refreshTimer?.cancel();
    refreshTimer = Timer.periodic(refreshInterval, (timer) {
      refreshRemoteConfig();
    });
  }

  void onWebViewCreated(InAppWebViewController controller) {
    webViewController = controller;
    _startLoadingTimeout();
  }

  void onLoadStart() {
    isLoading.value = true;
    hasError.value = false;
    _startLoadingTimeout();
  }

  Future<void> onLoadStop() async {
    isLoading.value = false;
    _cancelLoadingTimeout();

    if (autoHeight && !hasDetectedHeight.value) {
      await _detectAndUpdateHeight();
    }
  }

  void onLoadError(String error) {
    isLoading.value = false;
    hasError.value = true;
    errorMessage.value = error;
    _cancelLoadingTimeout();
  }

  Future<void> _detectAndUpdateHeight() async {
    if (webViewController == null) {
      return;
    }

    try {
      final detectedHeight =
          await TopIframeHelper.detectHeight(webViewController!);

      if (detectedHeight != null) {
        if (TopIframeHelper.shouldUpdateHeight(
            currentHeight.value, detectedHeight)) {
          currentHeight.value =
              TopIframeHelper.calculateContentHeight(detectedHeight);
          hasDetectedHeight.value = true;
        }
      } else {
        if (currentHeight.value < 350) {
          currentHeight.value = 350;
        }
      }

      hasDetectedHeight.value = true;
    } catch (e) {
      if (currentHeight.value < 350) {
        currentHeight.value = 350;
      }
      hasDetectedHeight.value = true;
    }
  }

  void _startLoadingTimeout() {
    _cancelLoadingTimeout();
    loadingTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (isLoading.value) {
        onLoadError('Loading timeout');
      }
    });
  }

  void _cancelLoadingTimeout() {
    loadingTimeoutTimer?.cancel();
    loadingTimeoutTimer = null;
  }

  void manualRefresh() {
    // 重新載入當前的 iframe 內容
    if (isVisible.value && currentUrl.value != null) {
      // 重新載入 WebView
      resetWebViewState();
    }
    // 同時重新抓取 Remote Config，以防設定有更新
    refreshRemoteConfig();
  }

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  @override
  void onClose() {
    refreshTimer?.cancel();
    loadingTimeoutTimer?.cancel();
    TopIframeHelper.safeDisposeWebView(webViewController);
    super.onClose();
  }
}
