import 'dart:convert';

class NotificationDeepLinkParser {
  static const List<String> _slugKeys = [
    'news_story_slug',
    'newsStorySlug',
    'story_slug',
    'storySlug',
    'post_slug',
    'postSlug',
    'article_slug',
    'articleSlug',
    'slug',
  ];

  static const List<String> _urlKeys = [
    'news_story_url',
    'newsStoryUrl',
    'story_url',
    'storyUrl',
    'article_url',
    'articleUrl',
    'deeplink',
    'deep_link',
    'deepLink',
    'url',
    'link',
  ];

  static String? extractStorySlug(Map<String, dynamic> data) {
    for (final key in _slugKeys) {
      final slug = _extractSlugFromValue(data[key], allowRawSlug: true);
      if (slug != null) return slug;
    }

    for (final key in _urlKeys) {
      final slug = _extractSlugFromValue(data[key], allowRawSlug: false);
      if (slug != null) return slug;
    }

    for (final value in data.values) {
      final slug = _extractSlugFromValue(value, allowRawSlug: false);
      if (slug != null) return slug;
    }

    return null;
  }

  static String? _extractSlugFromValue(
    Object? value, {
    required bool allowRawSlug,
  }) {
    if (value == null) return null;

    if (value is Map) {
      return extractStorySlug(Map<String, dynamic>.from(value));
    }

    if (value is Iterable) {
      for (final item in value) {
        final slug = _extractSlugFromValue(item, allowRawSlug: allowRawSlug);
        if (slug != null) return slug;
      }
      return null;
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) return null;

    final decodedPayloadSlug = _extractSlugFromJsonPayload(raw);
    if (decodedPayloadSlug != null) return decodedPayloadSlug;

    final urlSlug = _extractSlugFromUrlLikeValue(raw);
    if (urlSlug != null) return urlSlug;

    if (allowRawSlug && _looksLikeSlug(raw)) {
      return _cleanSlug(raw);
    }

    return null;
  }

  static String? _extractSlugFromJsonPayload(String raw) {
    final startsLikeJson = raw.startsWith('{') || raw.startsWith('[');
    if (!startsLikeJson) return null;

    try {
      final decoded = jsonDecode(raw);
      return _extractSlugFromValue(decoded, allowRawSlug: false);
    } catch (_) {
      return null;
    }
  }

  static String? _extractSlugFromUrlLikeValue(String raw) {
    final uri = Uri.tryParse(raw);
    if (uri == null) return null;

    final segments =
        uri.pathSegments
            .map((segment) => segment.trim())
            .where((segment) => segment.isNotEmpty)
            .toList();

    if (_isStoryPathHead(uri.host) && segments.isNotEmpty) {
      return _cleanSlug(segments.last);
    }

    for (var i = 0; i < segments.length - 1; i++) {
      if (_isStoryPathHead(segments[i])) {
        return _cleanSlug(segments.last);
      }
    }

    for (final key in _slugKeys) {
      final value = uri.queryParameters[key];
      if (value != null && value.trim().isNotEmpty) {
        return _cleanSlug(value);
      }
    }

    return null;
  }

  static bool _isStoryPathHead(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'story' || normalized == 'external';
  }

  static bool _looksLikeSlug(String raw) {
    if (raw.contains(RegExp(r'\s'))) return false;
    if (raw.contains('://')) return false;
    if (raw.startsWith('{') || raw.startsWith('[')) return false;
    return !raw.contains('/');
  }

  static String? _cleanSlug(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final withoutQuery = trimmed.split('?').first.split('#').first;
    final decoded = Uri.decodeComponent(withoutQuery).trim();
    if (decoded.isEmpty) return null;

    return decoded;
  }
}
