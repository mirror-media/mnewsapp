import 'dart:async';
import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TopIframeContentSize {
  const TopIframeContentSize({required this.width, required this.height});

  final double? width;
  final double height;
}

class TopIframeHelper {
  static const String contentSizeHandlerName = 'TopIframeContentSize';
  static int _nextWebViewKey = 0;

  // Measure an authored content root rather than the WebView's viewport. The
  // election page's section, for example, is narrower than its #__next host.
  static const String _contentSizeFunctions = r'''
  function visibleContentChildren(element) {
    return Array.from(element.children).filter(function(child) {
      if (/^(SCRIPT|STYLE|LINK|META|NOSCRIPT|TEMPLATE)$/.test(child.tagName)) {
        return false;
      }
      var style = window.getComputedStyle(child);
      var rect = child.getBoundingClientRect();
      return style.display !== 'none' && style.visibility !== 'hidden' &&
        style.position !== 'fixed' && rect.width > 0 && rect.height > 0;
    });
  }

  function findContentRoot() {
    var hosts = ['__next', 'root', 'app'];
    for (var i = 0; i < hosts.length; i++) {
      var host = document.getElementById(hosts[i]);
      if (!host) continue;
      var children = visibleContentChildren(host);
      if (children.length === 1) return children[0];
    }
    return null;
  }

  function measureContentSize(root) {
    var body = document.body;
    if (!body) return null;
    if (root) {
      var rect = root.getBoundingClientRect();
      if (Number.isFinite(rect.width) && rect.width > 0 &&
          Number.isFinite(rect.height) && rect.height > 0) {
        return {width: rect.width, height: rect.height};
      }
    }

    // For an arbitrary URL, keep the available width and measure visible
    // content without including html.clientHeight or document scrollHeight.
    var bottom = 0;
    visibleContentChildren(body).forEach(function(child) {
      var rect = child.getBoundingClientRect();
      var margin = parseFloat(window.getComputedStyle(child).marginBottom) || 0;
      bottom = Math.max(bottom, rect.bottom + window.scrollY + margin);
    });
    Array.from(body.childNodes).forEach(function(node) {
      if (node.nodeType !== Node.TEXT_NODE || !node.textContent.trim()) return;
      var range = document.createRange();
      range.selectNodeContents(node);
      var rect = range.getBoundingClientRect();
      bottom = Math.max(bottom, rect.bottom + window.scrollY);
    });
    if (bottom > 0) {
      var bodyStyle = window.getComputedStyle(body);
      bottom += (parseFloat(bodyStyle.paddingBottom) || 0) +
        (parseFloat(bodyStyle.marginBottom) || 0);
    }
    return {width: null, height: bottom > 0 ? Math.min(bottom, 800) : 350};
  }
''';

  static const String contentSizeDetectionScript = '''
(function() {
  var observer = window.__topIframeContentSizeObserver;
  if (observer && observer.measure) return observer.measure();
  $_contentSizeFunctions
  return measureContentSize(findContentRoot());
})();
''';

  static String contentSizeObserverScript(String observationToken) => '''
(function(token) {
  var previous = window.__topIframeContentSizeObserver;
  if (previous && previous.dispose) previous.dispose();
  $_contentSizeFunctions

  var disposed = false;
  var timer = null;
  var maxWaitTimer = null;
  var observed = [];
  var lastSize = null;
  var resizeObserver = typeof ResizeObserver === 'function'
    ? new ResizeObserver(schedule) : null;

  function updateObservedElements(root) {
    var next = root ? [root] : visibleContentChildren(document.body);
    if (!next.length && document.body) next = [document.body];
    if (next.length === observed.length && next.every(function(element, i) {
      return element === observed[i];
    })) return;
    if (resizeObserver) {
      resizeObserver.disconnect();
      next.forEach(function(element) { resizeObserver.observe(element); });
    }
    observed = next;
  }

  function measure() {
    if (disposed || !document.body) return null;
    var root = findContentRoot();
    updateObservedElements(root);
    var size = measureContentSize(root);
    if (size) size.token = token;
    return size;
  }

  function report() {
    if (timer !== null) window.clearTimeout(timer);
    if (maxWaitTimer !== null) window.clearTimeout(maxWaitTimer);
    timer = null;
    maxWaitTimer = null;
    if (disposed) return;
    var size = measure();
    if (!size) return;
    if (lastSize && lastSize.width === size.width &&
        Math.abs(lastSize.height - size.height) < 0.5) return;
    var bridge = window.flutter_inappwebview;
    if (!bridge || typeof bridge.callHandler !== 'function') return;
    lastSize = size;
    Promise.resolve(bridge.callHandler('$contentSizeHandlerName', size))
      .catch(function() {});
  }

  function schedule() {
    if (disposed) return;
    if (timer !== null) window.clearTimeout(timer);
    timer = window.setTimeout(report, 60);
    if (maxWaitTimer === null) maxWaitTimer = window.setTimeout(report, 250);
  }

  var mutationObserver = typeof MutationObserver === 'function'
    ? new MutationObserver(schedule) : null;
  if (mutationObserver && document.body) {
    mutationObserver.observe(document.body, {
      childList: true, subtree: true, characterData: true, attributes: true,
      attributeFilter: ['class', 'style', 'hidden']
    });
  }
  window.addEventListener('resize', schedule);
  window.addEventListener('flutterInAppWebViewPlatformReady', schedule);
  document.addEventListener('load', schedule, true);
  if (document.fonts && document.fonts.ready) {
    document.fonts.ready.then(schedule).catch(function() {});
  }

  window.__topIframeContentSizeObserver = {
    measure: measure,
    dispose: function() {
      disposed = true;
      if (timer !== null) window.clearTimeout(timer);
      if (maxWaitTimer !== null) window.clearTimeout(maxWaitTimer);
      if (resizeObserver) resizeObserver.disconnect();
      if (mutationObserver) mutationObserver.disconnect();
      window.removeEventListener('resize', schedule);
      window.removeEventListener('flutterInAppWebViewPlatformReady', schedule);
      document.removeEventListener('load', schedule, true);
    }
  };
  schedule();
})(${jsonEncode(observationToken)});
''';

  static InAppWebViewGroupOptions createWebViewSettings() {
    return InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
        javaScriptCanOpenWindowsAutomatically: false,
        supportZoom: false,
        disableContextMenu: false,
        clearCache: false,
        transparentBackground: false,
        verticalScrollBarEnabled: true,
        horizontalScrollBarEnabled: true,
        useShouldOverrideUrlLoading: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
        supportMultipleWindows: false,
        allowContentAccess: true,
        allowFileAccess: true,
        mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
        allowsBackForwardNavigationGestures: false,
        allowsLinkPreview: false,
        isFraudulentWebsiteWarningEnabled: false,
      ),
    );
  }

  static TopIframeContentSize? parseContentSize(dynamic value) {
    if (value is String) {
      try {
        value = jsonDecode(value);
      } on FormatException {
        return null;
      }
    }
    if (value is! Map) return null;

    final height = _positiveFiniteDouble(value['height']);
    if (height == null) return null;
    final rawWidth = value['width'];
    final width = _positiveFiniteDouble(rawWidth);
    if (rawWidth != null && width == null) return null;
    return TopIframeContentSize(width: width, height: height);
  }

  static double? _positiveFiniteDouble(dynamic value) {
    final number =
        value is num
            ? value.toDouble()
            : value is String
            ? double.tryParse(value)
            : null;
    return number != null && number.isFinite && number > 0 ? number : null;
  }

  static Future<void> installContentSizeObserver(
    InAppWebViewController controller, {
    required String observationToken,
  }) async {
    await controller.evaluateJavascript(
      source: contentSizeObserverScript(observationToken),
    );
  }

  static Future<TopIframeContentSize?> detectContentSize(
    InAppWebViewController controller,
  ) async {
    try {
      final result = await controller.evaluateJavascript(
        source: contentSizeDetectionScript,
      );
      return parseContentSize(result);
    } catch (_) {
      return null;
    }
  }

  static Future<double?> detectHeight(InAppWebViewController controller) async {
    return (await detectContentSize(controller))?.height;
  }

  static String generateWebViewKey(String url) {
    return '${url}_${DateTime.now().microsecondsSinceEpoch}_${_nextWebViewKey++}';
  }

  static bool shouldUpdateHeight(double currentHeight, double newHeight) {
    return newHeight.isFinite &&
        newHeight > 0 &&
        (newHeight - currentHeight).abs() >= 1;
  }

  static double calculateContentHeight(double contentHeight) {
    if (!contentHeight.isFinite || contentHeight <= 0) return 350;
    return contentHeight.ceilToDouble();
  }

  // The widget owns the native WebView. Only detach our observer and handler
  // here, so late messages cannot reach the controller for a different URL.
  static void safeDisposeWebView(InAppWebViewController? controller) {
    if (controller == null) return;
    try {
      controller.removeJavaScriptHandler(handlerName: contentSizeHandlerName);
    } catch (_) {}
    unawaited(_disconnectContentSizeObserver(controller));
  }

  static Future<void> _disconnectContentSizeObserver(
    InAppWebViewController controller,
  ) async {
    try {
      await controller.evaluateJavascript(
        source: '''
(function() {
  var observer = window.__topIframeContentSizeObserver;
  if (observer && observer.dispose) observer.dispose();
  delete window.__topIframeContentSizeObserver;
})();
''',
      );
    } catch (_) {}
  }
}
