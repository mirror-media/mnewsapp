import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:tv/helpers/top_iframe_helper.dart';
import 'package:tv/helpers/top_iframe_schedule.dart';

class TopIframeController extends GetxController with WidgetsBindingObserver {
  TopIframeController({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final DateTime Function() _now;

  static const _configKeys = {
    'isTopIframeShow',
    'topIframeUrl',
    'iframeTitle',
    'iframeShowMoreUrl',
    TopIframeSchedule.startAtKey,
    TopIframeSchedule.endAtKey,
  };

  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxnString errorMessage = RxnString();
  final RxDouble currentHeight = 400.0.obs;
  final RxnDouble currentWidth = RxnDouble();
  final RxnString currentUrl = RxnString();
  final RxnString webViewKey = RxnString();
  final RxBool isVisible = false.obs;
  final RxBool hasDetectedHeight = false.obs;
  final RxnString title = RxnString();
  final RxnString showMoreUrl = RxnString();

  InAppWebViewController? webViewController;
  Timer? refreshTimer;
  Timer? loadingTimeoutTimer;
  Timer? scheduleTimer;
  StreamSubscription<RemoteConfigUpdate>? _configUpdatesSubscription;

  late Duration refreshInterval;
  late bool autoHeight;
  late double initialHeight;

  bool _isDisposed = false;
  int _webViewGeneration = 0;
  int _documentGeneration = 0;
  String? _activeInstanceKey;
  String? _activeObservationToken;

  void initialize({
    Duration refreshInterval = const Duration(minutes: 1),
    bool autoHeight = true,
    double initialHeight = 400,
    bool waitForHeightDetection = false,
  }) {
    this.refreshInterval = refreshInterval;
    this.autoHeight = autoHeight;
    this.initialHeight = initialHeight;

    currentWidth.value = null;
    currentHeight.value = autoHeight ? 200 : initialHeight;
    webViewKey.value = TopIframeHelper.generateWebViewKey('');

    // Use the last activated settings even when a fresh fetch is unavailable.
    checkVisibility();
    _listenForConfigUpdates();
    _initializeRemoteConfig();
    startAutoRefresh();
  }

  Future<void> _initializeRemoteConfig() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );

      await _remoteConfig.fetch();
      await _remoteConfig.activate();
      checkVisibility();
    } catch (e) {
      // Silently handle errors.
    }
  }

  void checkVisibility() {
    if (_isDisposed) return;
    final isShow = _remoteConfig.getBool('isTopIframeShow');
    final url = _remoteConfig.getString('topIframeUrl');
    final titleText = _remoteConfig.getString('iframeTitle');
    final moreUrl = _remoteConfig.getString('iframeShowMoreUrl');
    final schedule = TopIframeSchedule.parse(
      startAt: _remoteConfig.getString(TopIframeSchedule.startAtKey),
      endAt: _remoteConfig.getString(TopIframeSchedule.endAtKey),
    );
    final now = _now();

    final isEnabled = isShow && url.isNotEmpty;
    final shouldBeVisible = isEnabled && schedule.isActiveAt(now);
    _scheduleNextTransition(isEnabled ? schedule : null, now);
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
    } else if (isVisible.value) {
      isVisible.value = false;
      currentUrl.value = null;
      currentWidth.value = null;
      _detachWebView();
      _cancelLoadingTimeout();
    }
  }

  void _scheduleNextTransition(TopIframeSchedule? schedule, DateTime now) {
    scheduleTimer?.cancel();
    scheduleTimer = null;
    final nextTransition = schedule?.nextTransitionAfter(now);
    if (nextTransition == null) return;

    scheduleTimer = Timer(nextTransition.difference(now), () {
      scheduleTimer = null;
      if (!_isDisposed) checkVisibility();
    });
  }

  void _listenForConfigUpdates() {
    unawaited(_configUpdatesSubscription?.cancel());
    try {
      _configUpdatesSubscription = _remoteConfig.onConfigUpdated.listen(
        (update) async {
          if (_isDisposed || !update.updatedKeys.any(_configKeys.contains)) {
            return;
          }
          try {
            await _remoteConfig.activate();
            checkVisibility();
          } catch (_) {
            // The existing periodic fetch retries when the connection returns.
          }
        },
        onError: (Object error) {
          // Keep the last activated schedule and periodic refresh on errors.
        },
      );
    } catch (_) {
      // Platforms without real-time updates still use the periodic fetch.
    }
  }

  Future<void> refreshRemoteConfig() async {
    if (_isDisposed) return;
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );

      await _remoteConfig.fetch();
      await _remoteConfig.activate();
      checkVisibility();
    } catch (e) {
      // Silently handle errors.
    }
  }

  void resetWebViewState() {
    _detachWebView();
    isLoading.value = true;
    hasError.value = false;
    hasDetectedHeight.value = false;
    errorMessage.value = null;

    currentWidth.value = null;
    currentHeight.value = autoHeight ? 200 : initialHeight;
    webViewKey.value = TopIframeHelper.generateWebViewKey(
      currentUrl.value ?? '',
    );
    _cancelLoadingTimeout();
  }

  void startAutoRefresh() {
    refreshTimer?.cancel();
    refreshTimer = Timer.periodic(refreshInterval, (timer) {
      // Re-evaluate cached settings independently of network availability.
      checkVisibility();
      refreshRemoteConfig();
    });
  }

  void onWebViewCreated(
    InAppWebViewController controller, {
    String? instanceKey,
  }) {
    final key = instanceKey ?? webViewKey.value;
    if (_isDisposed || !isVisible.value || key != webViewKey.value) return;

    _detachWebView();
    webViewController = controller;
    _activeInstanceKey = key;
    final generation = _webViewGeneration;
    controller.addJavaScriptHandler(
      handlerName: TopIframeHelper.contentSizeHandlerName,
      callback: (arguments) {
        if (!_isCurrentWebView(controller, key) ||
            generation != _webViewGeneration ||
            hasError.value ||
            arguments.isEmpty) {
          return null;
        }
        final payload = arguments.first;
        if (payload is! Map ||
            _activeObservationToken == null ||
            payload['token'] != _activeObservationToken) {
          return null;
        }
        final size = TopIframeHelper.parseContentSize(payload);
        if (size != null) _applyContentSize(size);
        return null;
      },
    );
    _startLoadingTimeout();
  }

  void onLoadStart({
    InAppWebViewController? webController,
    String? instanceKey,
  }) {
    final view = webController ?? webViewController;
    if (view == null || !_isCurrentWebView(view, instanceKey)) return;
    _documentGeneration++;
    _activeObservationToken = null;
    currentWidth.value = null;
    hasDetectedHeight.value = false;
    isLoading.value = true;
    hasError.value = false;
    _startLoadingTimeout();
  }

  Future<void> onLoadStop({
    InAppWebViewController? webController,
    String? instanceKey,
  }) async {
    final view = webController ?? webViewController;
    if (view == null || !_isCurrentWebView(view, instanceKey)) return;
    isLoading.value = false;
    _cancelLoadingTimeout();
    await _detectAndObserveContentSize(view, instanceKey);
  }

  void onLoadError(
    String error, {
    InAppWebViewController? webController,
    String? instanceKey,
  }) {
    final view = webController ?? webViewController;
    if (view == null || !_isCurrentWebView(view, instanceKey)) return;
    _documentGeneration++;
    _activeObservationToken = null;
    isLoading.value = false;
    hasError.value = true;
    errorMessage.value = error;
    _cancelLoadingTimeout();
  }

  Future<void> _detectAndObserveContentSize(
    InAppWebViewController view,
    String? instanceKey,
  ) async {
    final generation = _webViewGeneration;
    final documentGeneration = _documentGeneration;
    final token = '${_activeInstanceKey}_${generation}_$documentGeneration';
    _activeObservationToken = token;
    try {
      await TopIframeHelper.installContentSizeObserver(
        view,
        observationToken: token,
      );
    } catch (_) {
      // A one-shot measurement still works when observers are unavailable.
    }
    if (!_isCurrentDocument(
      view,
      instanceKey,
      generation,
      documentGeneration,
    )) {
      return;
    }
    final size = await TopIframeHelper.detectContentSize(view);
    if (!_isCurrentDocument(
      view,
      instanceKey,
      generation,
      documentGeneration,
    )) {
      return;
    }
    if (size != null) {
      _applyContentSize(size);
    } else if (autoHeight && !hasDetectedHeight.value) {
      currentHeight.value = 350;
    }
  }

  void _applyContentSize(TopIframeContentSize size) {
    final width = size.width;
    if (width == null) {
      currentWidth.value = null;
    } else if (currentWidth.value == null ||
        (currentWidth.value! - width).abs() >= 1) {
      currentWidth.value = width;
    }

    if (autoHeight) {
      final height = TopIframeHelper.calculateContentHeight(size.height);
      if (TopIframeHelper.shouldUpdateHeight(currentHeight.value, height)) {
        currentHeight.value = height;
      }
      hasDetectedHeight.value = true;
    }
  }

  bool _isCurrentWebView(InAppWebViewController view, String? instanceKey) {
    // Creation and navigation callbacks can use different Dart wrappers for
    // the same platform controller on iOS and Android. Match that controller,
    // while retaining the instance key and generation guards for stale views.
    return !_isDisposed &&
        isVisible.value &&
        identical(webViewController?.platform, view.platform) &&
        _activeInstanceKey == webViewKey.value &&
        (instanceKey == null || instanceKey == _activeInstanceKey);
  }

  bool _isCurrentDocument(
    InAppWebViewController view,
    String? instanceKey,
    int generation,
    int documentGeneration,
  ) {
    return _isCurrentWebView(view, instanceKey) &&
        !hasError.value &&
        generation == _webViewGeneration &&
        documentGeneration == _documentGeneration;
  }

  void _detachWebView() {
    _webViewGeneration++;
    _documentGeneration++;
    _activeInstanceKey = null;
    _activeObservationToken = null;
    final previousView = webViewController;
    webViewController = null;
    TopIframeHelper.safeDisposeWebView(previousView);
  }

  void _startLoadingTimeout() {
    _cancelLoadingTimeout();
    final view = webViewController;
    final key = _activeInstanceKey;
    final generation = _webViewGeneration;
    final documentGeneration = _documentGeneration;
    loadingTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (view != null &&
          _isCurrentDocument(view, key, generation, documentGeneration) &&
          isLoading.value) {
        onLoadError('Loading timeout', webController: view, instanceKey: key);
      }
    });
  }

  void _cancelLoadingTimeout() {
    loadingTimeoutTimer?.cancel();
    loadingTimeoutTimer = null;
  }

  void manualRefresh() {
    if (isVisible.value && currentUrl.value != null) {
      resetWebViewState();
    }
    refreshRemoteConfig();
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isDisposed && state == AppLifecycleState.resumed) {
      checkVisibility();
      unawaited(refreshRemoteConfig());
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    refreshTimer?.cancel();
    scheduleTimer?.cancel();
    scheduleTimer = null;
    unawaited(_configUpdatesSubscription?.cancel());
    _configUpdatesSubscription = null;
    _cancelLoadingTimeout();
    _detachWebView();
    super.onClose();
  }
}
