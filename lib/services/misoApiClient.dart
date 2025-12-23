import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:tv/models/misoSearch.dart';

class MisoApiClient {
  final String apiKey;
  final http.Client _client;

  MisoApiClient({
    required this.apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://api.askmiso.com';

  Future<MisoHybridSearchResponse> hybridSearch(
      MisoHybridSearchRequest request,
      ) async {
    final uri = Uri.parse('$_baseUrl/v1/ask/search')
        .replace(queryParameters: {'api_key': apiKey});

    final res = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Miso hybridSearch failed: ${res.statusCode} ${res.body}');
    }

    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    return MisoHybridSearchResponse.fromJson(jsonMap);
  }

  Future<MisoAnswerResponse?> getAnswerWithProgress(
      String questionId, {
        int maxRetries = 10,
        Duration interval = const Duration(seconds: 1),
      }) async {
    for (var i = 0; i < maxRetries; i++) {
      final uri = Uri.parse('$_baseUrl/v1/ask/questions/$questionId/answer')
          .replace(queryParameters: {'api_key': apiKey});

      final res = await _client.get(uri);

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('Miso getAnswer failed: ${res.statusCode} ${res.body}');
      }

      final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
      final parsed = MisoAnswerResponse.fromJson(jsonMap);

      if (parsed.data.status == 'success') return parsed;

      await Future.delayed(interval);
    }
    return null;
  }
}
