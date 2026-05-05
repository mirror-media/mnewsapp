import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class YtEmbeddedCodeWidget extends StatefulWidget {
  final String embeddedCode;
  final double? aspectRatio;

  const YtEmbeddedCodeWidget({
    Key? key,
    required this.embeddedCode,
    this.aspectRatio,
  }) : super(key: key);

  @override
  State<YtEmbeddedCodeWidget> createState() => _YtEmbeddedCodeWidgetState();
}

class _YtEmbeddedCodeWidgetState extends State<YtEmbeddedCodeWidget> {
  WebViewController? _controller;
  late double _aspectRatio;
  String? _iframeSrc;

  @override
  void initState() {
    super.initState();

    _iframeSrc = _extractSrcFromIframe(widget.embeddedCode);
    _aspectRatio = widget.aspectRatio ?? _extractAspectRatio();

    if (_iframeSrc != null) {
      final htmlContent = '''
        <!DOCTYPE html>
        <html>
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
              body, html {
                margin: 0;
                padding: 0;
                background-color: black;
                overflow: hidden;
              }
              .video-container {
                position: relative;
                width: 100%;
                padding-top: ${100 / _aspectRatio}%;
              }
              .video-container iframe {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                border: none;
              }
            </style>
          </head>
          <body>
            <div class="video-container">
              <iframe
                src="$_iframeSrc"
                title="YouTube video player"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                allowfullscreen>
              </iframe>
            </div>
          </body>
        </html>
      ''';

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadHtmlString(htmlContent);
    }
  }

  double _extractAspectRatio() {
    try {
      final width = RegExp(r'width="(\d+)"')
          .firstMatch(widget.embeddedCode)
          ?.group(1);
      final height = RegExp(r'height="(\d+)"')
          .firstMatch(widget.embeddedCode)
          ?.group(1);
      if (width != null && height != null) {
        return double.parse(width) / double.parse(height);
      }
    } catch (_) {}
    return 16 / 9;
  }

  String? _extractSrcFromIframe(String code) {
    final match = RegExp(r'src="([^"]+)"').firstMatch(code);
    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    if (_iframeSrc == null || _controller == null) {
      return const SizedBox(); // 或 Text("無法顯示影片")
    }

    return LayoutBuilder(
      builder: (_, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxWidth / _aspectRatio,
          child: WebViewWidget(controller: _controller!),
        );
      },
    );
  }
}
