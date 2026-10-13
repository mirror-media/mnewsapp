import 'dart:convert';

import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;
import 'package:tv/helpers/environment.dart';

class OmbudsTitleService {
  OmbudsTitleService({
    http.Client? client,
    this.timeout = const Duration(seconds: 5),
  }) : _client = client;

  final http.Client? _client;
  final Duration timeout;

  Future<String?> fetchTitle() async {
    final uri = Uri.parse(Environment().config.ombudsAppealUrl);
    final client = _client ?? http.Client();

    try {
      final response = await client
          .get(uri, headers: {'Cache-Control': 'no-cache'})
          .timeout(timeout);
      if (response.statusCode != 200) {
        throw http.ClientException(
          'Ombuds page returned HTTP ${response.statusCode}',
          uri,
        );
      }

      // biography.name is the article title, not the heading on /ombuds.
      final document = html.parse(utf8.decode(response.bodyBytes));
      for (final heading in document.querySelectorAll('h1')) {
        final title = heading.text.trim();
        if (title.startsWith('外部公評人') && title != '外部公評人') {
          return title;
        }
      }
      return null;
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }
}
