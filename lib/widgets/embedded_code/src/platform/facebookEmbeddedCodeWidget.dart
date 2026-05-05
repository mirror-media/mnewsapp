import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'embeddedCodeShared.dart';

class FacebookEmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCode;
  const FacebookEmbeddedCodeWidget({
    Key? key,
    required this.embeddedCode,
  }) : super(key: key);

  @override
  _FacebookEmbeddedCodeWidgetState createState() =>
      _FacebookEmbeddedCodeWidgetState();
}

class _FacebookEmbeddedCodeWidgetState
    extends State<FacebookEmbeddedCodeWidget> {
  double _aspectRatio = 16 / 9;
  bool _isVertical = false;

  @override
  void initState() {
    _aspectRatio = extractIframeAspectRatio(widget.embeddedCode);
    if (_aspectRatio < 16 / 9) {
      _isVertical = true;
    }
    super.initState();
  }

  String _getHtml(String embeddedCode, double width) {
    return buildEmbeddedHtml(
      embeddedCode: embeddedCode,
      widgetStyle: '''
display: flex;
justify-content: center;
margin: 0 auto;
max-width: 100%;
''',
      scripts: '''
    <style>
      iframe { margin: 0; width: 100%; }
    </style>
''',
      includeDynamicAspectRatioScripts: true,
    );
  }

  void _setAspectRatio(double aspectRatio) {
    if (aspectRatio != 0 && _isVertical) {
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
            child: WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..addJavaScriptChannel(
                  'PageAspectRatio',
                  onMessageReceived: (message) {
                    _setAspectRatio(double.parse(message.message));
                  },
                )
                ..loadRequest(
                  embeddedCodeHtmlUri(
                    _getHtml(widget.embeddedCode, constraints.maxWidth),
                  ),
                ),
            ),
          );
        });
  }
}
