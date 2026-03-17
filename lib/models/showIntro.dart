import 'dart:convert';

import 'package:tv/helpers/environment.dart';
import 'package:tv/models/youtubePlaylistInfo.dart';

class ShowIntro {
  final String name;
  final String introduction;
  final String pictureUrl;

  final YoutubePlaylistInfo? playList01;
  final YoutubePlaylistInfo? playList02;

  ShowIntro({
    required this.name,
    required this.introduction,
    required this.pictureUrl,
    this.playList01,
    this.playList02,
  });

  factory ShowIntro.fromJson(Map<String, dynamic> json) {
    final picture = json['picture'];

    final String pictureUrl =
        _extractImage(picture) ??
            Environment().config.mirrorNewsDefaultImageUrl;

    return ShowIntro(
      name: json['name']?.toString() ?? '',
      introduction: json['introduction']?.toString() ?? '',
      pictureUrl: pictureUrl,
      playList01: YoutubePlaylistInfo.parseByShow(json['playList01'], '選單 A'),
      playList02: YoutubePlaylistInfo.parseByShow(json['playList02'], '選單 B'),
    );
  }

  static String? _extractImage(dynamic node) {
    if (node == null || node is! Map) return null;

    final map = Map<String, dynamic>.from(node);

    // 1. 優先抓 resized（這是你目前 show 真實資料最穩的來源）
    final resized = map['resized'];
    final resizedUrl = _extractFromStringMap(
      resized,
      priority: const ['w800', 'w480', 'w1600', 'w2400', 'original', 'w1200'],
    );
    if (resizedUrl != null && resizedUrl.isNotEmpty) {
      return resizedUrl;
    }

    // 2. 再抓 resizedWebp
    final resizedWebp = map['resizedWebp'];
    final resizedWebpUrl = _extractFromStringMap(
      resizedWebp,
      priority: const ['w800', 'w480', 'w1600', 'w2400', 'original', 'w1200'],
    );
    if (resizedWebpUrl != null && resizedWebpUrl.isNotEmpty) {
      return resizedWebpUrl;
    }

    // 3. 再抓 imageApiData（你的資料裡是 Map，不是單純字串）
    final imageApiDataUrl = _extractFromImageApiData(map['imageApiData']);
    if (imageApiDataUrl != null && imageApiDataUrl.isNotEmpty) {
      return imageApiDataUrl;
    }

    // 4. 最後才抓 file.url
    final file = map['file'];
    if (file is Map) {
      final fileMap = Map<String, dynamic>.from(file);
      final fileUrl = fileMap['url'];
      if (fileUrl is String && fileUrl.isNotEmpty) {
        // file.url 可能是相對路徑，如 /images/xxx.jpg
        if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
          return fileUrl;
        }
      }
    }

    return null;
  }

  static String? _extractFromStringMap(
      dynamic value, {
        required List<String> priority,
      }) {
    if (value is! Map) return null;

    final map = Map<String, dynamic>.from(value);

    for (final key in priority) {
      final v = map[key];
      if (v is String && v.isNotEmpty) {
        return v;
      }
    }

    return null;
  }

  static String? _extractFromImageApiData(dynamic imageApiData) {
    if (imageApiData == null) return null;

    if (imageApiData is String) {
      final trimmed = imageApiData.trim();
      if (trimmed.isEmpty) return null;

      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return trimmed;
      }

      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          final decoded = json.decode(trimmed);
          return _extractFromImageApiData(decoded);
        } catch (_) {
          return null;
        }
      }

      return null;
    }

    if (imageApiData is Map) {
      final map = Map<String, dynamic>.from(imageApiData);

      final directUrl = map['url'];
      if (directUrl is String && directUrl.isNotEmpty) {
        return directUrl;
      }

      const keys = ['w800', 'w480', 'w1600', 'w2400', 'original', 'w1200'];

      for (final key in keys) {
        final value = map[key];

        if (value is String && value.isNotEmpty) {
          return value;
        }

        if (value is Map) {
          final nested = Map<String, dynamic>.from(value);
          final nestedUrl = nested['url'];
          if (nestedUrl is String && nestedUrl.isNotEmpty) {
            return nestedUrl;
          }
        }
      }
    }

    return null;
  }
}