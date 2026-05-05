import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'embeddedCodeShared.dart';

class GoogleMapEmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCode;
  const GoogleMapEmbeddedCodeWidget({
    Key? key,
    required this.embeddedCode,
  }) : super(key: key);

  @override
  _GoogleMapEmbeddedCodeWidgetState createState() =>
      _GoogleMapEmbeddedCodeWidgetState();
}

class _GoogleMapEmbeddedCodeWidgetState
    extends State<GoogleMapEmbeddedCodeWidget> {
  final double _aspectRatio = 8 / 7;
  String _getHtml(String embeddedCode) {
    return buildEmbeddedHtml(
      embeddedCode: embeddedCode,
      widgetStyle: '''
display: flex;
justify-content: left;
margin: 0 auto;
max-width: 100%;
''',
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxWidth / _aspectRatio,
            child: WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(embeddedCodeHtmlUri(_getHtml(widget.embeddedCode)))
            ),
          );
        });
  }
}
