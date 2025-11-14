class StoryHtmlHelper {
  static bool isNullOrEmpty(String? input) =>
      input == null || input.isEmpty;

  static bool looksLikeHtml(String s) {
    return RegExp(r'<[^>]+>').hasMatch(s);
  }

  static String? sanitizeExternalHtml(String? html) {
    if (html == null) return null;
    var s = html.trim();
    if (s.isEmpty) return null;

    s = s
        .replaceAll(r'\"', '"')
        .replaceAll(r"\'", "'")
        .replaceAll(r'\/', '/')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\t', '\t');

    s = s
        .replaceAll(RegExp(r'<\s*figure\b', caseSensitive: false), '<div')
        .replaceAll(RegExp(r'</\s*figure\s*>', caseSensitive: false), '</div>');

    return s;
  }
}