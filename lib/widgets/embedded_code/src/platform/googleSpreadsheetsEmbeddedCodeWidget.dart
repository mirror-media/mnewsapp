import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'embeddedCodeShared.dart';

class GoogleSpreadsheetsEmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCode;
  const GoogleSpreadsheetsEmbeddedCodeWidget({
    Key? key,
    required this.embeddedCode,
  }) : super(key: key);

  @override
  _GoogleSpreadsheetsEmbeddedCodeWidgetState createState() =>
      _GoogleSpreadsheetsEmbeddedCodeWidgetState();
}

class _GoogleSpreadsheetsEmbeddedCodeWidgetState
    extends State<GoogleSpreadsheetsEmbeddedCodeWidget> {
  double _aspectRatio = 16 / 9;
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _aspectRatio = extractIframeAspectRatio(widget.embeddedCode);
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(embeddedCodeHtmlUri(_getHtml(widget.embeddedCode)));
  }

  String _getHtml(String embeddedCode) {
    return buildEmbeddedHtml(
      embeddedCode: embeddedCode,
      head: '<meta name="viewport" content="width=device-width, initial-scale=0.85">',
      widgetStyle: '''
display: flex;
justify-content: center;
margin: 0 auto;
max-width: 100%;
''',
      scripts: '''
    <style>
      iframe {
        margin: 0;
        width: 100%;
        padding: 0;
      }
    </style>
''',
      includeDynamicAspectRatioScripts: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxWidth / _aspectRatio,
            child: WebViewWidget(controller: _webViewController),
          );
        });
  }
}
