import 'dart:convert';

Uri embeddedCodeHtmlUri(String html) {
  return Uri.dataFromString(
    html,
    mimeType: 'text/html',
    encoding: Encoding.getByName('utf-8'),
  );
}

double extractIframeAspectRatio(
  String embeddedCode, {
  double fallback = 16 / 9,
}) {
  final widthRegExp = RegExp(
    r'width="(.[0-9]*)"',
    caseSensitive: false,
  );
  final heightRegExp = RegExp(
    r'height="(.[0-9]*)"',
    caseSensitive: false,
  );
  final iframeWidth = double.tryParse(
    widthRegExp.firstMatch(embeddedCode)?.group(1) ?? '',
  );
  final iframeHeight = double.tryParse(
    heightRegExp.firstMatch(embeddedCode)?.group(1) ?? '',
  );

  if (iframeWidth == null || iframeHeight == null) {
    return fallback;
  }

  return iframeWidth / iframeHeight;
}

String buildEmbeddedHtml({
  required String embeddedCode,
  required String widgetStyle,
  String head = '',
  String scripts = '',
  bool includeDynamicAspectRatioScripts = false,
}) {
  final dynamicScripts = includeDynamicAspectRatioScripts
      ? '$dynamicAspectRatioScriptSetup\n    $dynamicAspectRatioScriptCheck'
      : '';

  return '''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    $head
    <style>
      * { box-sizing: border-box; margin: 0; padding: 0; }
      #widget {
        $widgetStyle
      }
    </style>
  </head>
  <body>
    <div id="widget">$embeddedCode</div>
    $dynamicScripts
    $scripts
  </body>
</html>
''';
}

const String dynamicAspectRatioScriptSetup = """
    <script type="text/javascript">
      const widget = document.getElementById('widget');
      const sendAspectRatio = () => PageAspectRatio.postMessage(widget.clientWidth / widget.clientHeight);
    </script>
  """;

const String dynamicAspectRatioScriptCheck = """
    <script type="text/javascript">
      const onWidgetResize = (widgets) => sendAspectRatio();
      const resize_ob = new ResizeObserver(onWidgetResize);
      resize_ob.observe(widget);
    </script>
  """;
