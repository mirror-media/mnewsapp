import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'embeddedCodeShared.dart';

class TwitterEmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCode;
  const TwitterEmbeddedCodeWidget({
    Key? key,
    required this.embeddedCode,
  }) : super(key: key);

  @override
  _TwitterEmbeddedCodeWidgetState createState() =>
      _TwitterEmbeddedCodeWidgetState();
}

class _TwitterEmbeddedCodeWidgetState extends State<TwitterEmbeddedCodeWidget> {
  double _aspectRatio = 16 / 9;
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('PageAspectRatio', onMessageReceived: (message) {
        _setAspectRatio(double.parse(message.message));
      })
      ..loadRequest(embeddedCodeHtmlUri(_getHtml(widget.embeddedCode)));
  }

  String _getHtml(String embeddedCode) {
    return buildEmbeddedHtml(
      embeddedCode: embeddedCode,
      widgetStyle: '''
display: flex;
justify-content: center;
margin: 0 auto;
max-width: 100%;
''',
      includeDynamicAspectRatioScripts: true,
    );
  }

  void _setAspectRatio(double aspectRatio) {
    if (aspectRatio != 0) {
      setState(() {
        _aspectRatio = aspectRatio;
      });
    }
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
      },
    );
  }
}
