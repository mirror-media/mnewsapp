import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../model/election_data.dart';

class ElectionDataProvider extends GetConnect {
  String? apiUrl = '';

  ElectionDataProvider._(this.apiUrl);

  static ElectionDataProvider? _instance;

  factory ElectionDataProvider.create(String api) {
    _instance ??= ElectionDataProvider._(api);
    return _instance!;
  }

  final http.Client _client = http.Client();

  ElectionDataProvider(String this.apiUrl);

  Future<ElectionData?> getElectionData() async {
    if (apiUrl == null) return null;

    DateTime time = DateTime.now();
    final response = await _client
        .get(Uri.parse('$apiUrl?t=${time.millisecondsSinceEpoch}'));
    if (response.statusCode == 200) {
      String utf8Json = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = json.decode(utf8Json);
      return ElectionData.fromJson(data);
    } else {
      print('Failed to load post, status code: ${response.statusCode}');
      return null;
    }
  }
}
