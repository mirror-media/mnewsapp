import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TopIframeHelper {
  static const String _heightDetectionScript = '''
(function() {
  try {
    var body = document.body;
    var html = document.documentElement;
    
    if (!body || !html) {
      return 400;
    }
    
    // 使用多種方法檢測高度
    var scrollHeight = Math.max(
      body.scrollHeight || 0,
      body.offsetHeight || 0,
      html.clientHeight || 0,
      html.scrollHeight || 0,
      html.offsetHeight || 0
    );
    
    // 檢查所有可見元素的邊界，但只看主要內容元素
    var contentElements = document.querySelectorAll('div, section, article, main, table, img, canvas, svg');
    var maxBottom = 0;
    var visibleElements = 0;
    
    for (var i = 0; i < contentElements.length; i++) {
      var element = contentElements[i];
      var rect = element.getBoundingClientRect();
      
      if (rect.height > 0 && rect.width > 0) {
        visibleElements++;
        var bottom = rect.bottom + window.pageYOffset;
        if (bottom > maxBottom) {
          maxBottom = bottom;
        }
      }
    }
    
    // 選擇最合適的高度，偏向較小的值以避免空白
    var finalHeight = Math.min(
      Math.max(scrollHeight, maxBottom),
      scrollHeight > 0 ? scrollHeight : maxBottom
    );
    
    // 如果都沒有合理值，使用預設
    if (finalHeight <= 0 || finalHeight < 200) {
      finalHeight = 400;
    }
    
    // 限制最大高度，進一步減少緩衝空間
    var result = Math.min(finalHeight + 5, 800);
    
    return result;
    
  } catch (e) {
    return 400;
  }
})();
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

  static Future<double?> detectHeight(InAppWebViewController controller) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final result =
          await controller.evaluateJavascript(source: _heightDetectionScript);

      if (result != null) {
        double? jsHeight = double.tryParse(result.toString());

        if (jsHeight != null && jsHeight > 100) {
          double finalHeight = jsHeight > 800 ? 800 : jsHeight;
          return finalHeight;
        }
      }

      return 350.0;
    } catch (e) {
      return 350.0;
    }
  }

  static String generateWebViewKey(String url) {
    return '${url}_${DateTime.now().millisecondsSinceEpoch}';
  }

  static bool shouldUpdateHeight(double currentHeight, double newHeight) {
    return (newHeight - currentHeight).abs() > 10;
  }

  static double calculateContentHeight(double contentHeight) {
    if (contentHeight <= 0) return 350;
    return contentHeight > 800 ? 800 : contentHeight;
  }

  static void safeDisposeWebView(InAppWebViewController? controller) {}
}
