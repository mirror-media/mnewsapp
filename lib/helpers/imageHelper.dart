import 'dart:convert';

class ImageHelper {
  static String? extractImage(dynamic node) {
    if (node == null) return null;

    if (node is String) {
      final trimmed = node.trim();
      if (trimmed.isEmpty) return null;

      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return trimmed;
      }

      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          final decoded = json.decode(trimmed);
          return extractImage(decoded);
        } catch (_) {
          return null;
        }
      }

      return null;
    }

    if (node is! Map) return null;

    final map = Map<String, dynamic>.from(node);

    final resizedUrl = _extractFromStringMap(
      map['resized'],
      priority: const ['w800', 'w480', 'w1600', 'w2400', 'original', 'w1200'],
    );
    if (resizedUrl != null && resizedUrl.isNotEmpty) {
      return resizedUrl;
    }

    final resizedWebpUrl = _extractFromStringMap(
      map['resizedWebp'],
      priority: const ['w800', 'w480', 'w1600', 'w2400', 'original', 'w1200'],
    );
    if (resizedWebpUrl != null && resizedWebpUrl.isNotEmpty) {
      return resizedWebpUrl;
    }

    final imageApiDataUrl = _extractFromImageApiData(map['imageApiData']);
    if (imageApiDataUrl != null && imageApiDataUrl.isNotEmpty) {
      return imageApiDataUrl;
    }

    final file = map['file'];
    if (file is Map) {
      final fileMap = Map<String, dynamic>.from(file);
      final fileUrl = fileMap['url'];
      if (fileUrl is String && fileUrl.isNotEmpty) {
        if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
          return fileUrl;
        }
      }
    }

    final directUrl = map['url'];
    if (directUrl is String && directUrl.isNotEmpty) {
      return directUrl;
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

      if (v is Map) {
        final nested = Map<String, dynamic>.from(v);
        final nestedUrl = nested['url'];
        if (nestedUrl is String && nestedUrl.isNotEmpty) {
          return nestedUrl;
        }
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