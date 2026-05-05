import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'embeddedCodeShared.dart';

class GoogleDocsEmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCode;
  const GoogleDocsEmbeddedCodeWidget({
    Key? key,
    required this.embeddedCode,
  }) : super(key: key);

  @override
  _GoogleDocsEmbeddedCodeWidgetState createState() =>
      _GoogleDocsEmbeddedCodeWidgetState();
}

class _GoogleDocsEmbeddedCodeWidgetState
    extends State<GoogleDocsEmbeddedCodeWidget> {
  double _aspectRatio = 16 / 9;

  @override
  void initState() {
    super.initState();
    _aspectRatio = extractIframeAspectRatio(widget.embeddedCode);
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
            child: WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..addJavaScriptChannel(
                  'PageAspectRatio',
                  onMessageReceived: (JavaScriptMessage message) {
                    _setAspectRatio(double.parse(message.message));
                  },
                )
                ..loadRequest(
                  embeddedCodeHtmlUri(_getHtml(widget.embeddedCode)),
                )
            ),
          );
        });
  }
}
