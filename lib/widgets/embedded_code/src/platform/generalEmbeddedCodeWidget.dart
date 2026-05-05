import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'embeddedCodeShared.dart';

class GeneralEmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCode;

  const GeneralEmbeddedCodeWidget({
    Key? key,
    required this.embeddedCode,
  }) : super(key: key);

  @override
  _GeneralEmbeddedCodeWidgetState createState() =>
      _GeneralEmbeddedCodeWidgetState();
}

class _GeneralEmbeddedCodeWidgetState extends State<GeneralEmbeddedCodeWidget> {
  double _aspectRatio = 16 / 9;

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
        child: WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..addJavaScriptChannel(
              'PageAspectRatio',
              onMessageReceived: (JavaScriptMessage message) {
                _setAspectRatio(double.parse(message.message));
              },
            )
            ..loadHtmlString(
              _getHtml(widget.embeddedCode),
              baseUrl: embeddedCodeHtmlUri('').toString(),
            )
        ),
      );
    });
  }
}
