import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String _youtubeEmbedOrigin = 'https://www.mnews.tw';
const String _youtubeEmbedBaseUrl = '$_youtubeEmbedOrigin/';

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

    _iframeSrc = _normalizeYoutubeEmbedSrc(
      _extractSrcFromIframe(widget.embeddedCode),
    );
    _aspectRatio = widget.aspectRatio ?? _extractAspectRatio();

    if (_iframeSrc != null) {
      final escapedIframeSrc = const HtmlEscape().convert(_iframeSrc!);
      final htmlContent = '''
        <!DOCTYPE html>
        <html>
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <meta name="referrer" content="strict-origin-when-cross-origin">
            <base href="$_youtubeEmbedBaseUrl">
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
                src="$escapedIframeSrc"
                title="YouTube video player"
                referrerpolicy="strict-origin-when-cross-origin"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                allowfullscreen>
              </iframe>
            </div>
          </body>
        </html>
      ''';

      _controller =
          WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadHtmlString(htmlContent, baseUrl: _youtubeEmbedBaseUrl);
    }
  }

  double _extractAspectRatio() {
    try {
      final width = RegExp(
        r'width="(\d+)"',
      ).firstMatch(widget.embeddedCode)?.group(1);
      final height = RegExp(
        r'height="(\d+)"',
      ).firstMatch(widget.embeddedCode)?.group(1);
      if (width != null && height != null) {
        return double.parse(width) / double.parse(height);
      }
    } catch (_) {}
    return 16 / 9;
  }

  String? _extractSrcFromIframe(String code) {
    final match = RegExp(
      r'''src\s*=\s*["']([^"']+)["']''',
      caseSensitive: false,
    ).firstMatch(code);
    return match?.group(1);
  }

  String? _normalizeYoutubeEmbedSrc(String? src) {
    if (src == null || src.trim().isEmpty) return null;

    final unescapedSrc = src
        .trim()
        .replaceAll('&amp;', '&')
        .replaceAll('&#38;', '&');
    final normalizedSrc =
        unescapedSrc.startsWith('//') ? 'https:$unescapedSrc' : unescapedSrc;
    final uri = Uri.tryParse(normalizedSrc);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return normalizedSrc;
    }

    final queryParameters = Map<String, String>.from(uri.queryParameters);
    queryParameters.putIfAbsent('origin', () => _youtubeEmbedOrigin);
    queryParameters.putIfAbsent('playsinline', () => '1');

    return uri.replace(queryParameters: queryParameters).toString();
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
