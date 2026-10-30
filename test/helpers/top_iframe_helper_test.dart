import 'package:flutter_test/flutter_test.dart';
import 'package:tv/helpers/top_iframe_helper.dart';

void main() {
  group('iframe content size messages', () {
    test('accepts natural dimensions without adding blank space', () {
      final size = TopIframeHelper.parseContentSize({
        'width': 320,
        'height': 330,
      });

      expect(size, isNotNull);
      expect(size!.width, 320);
      expect(TopIframeHelper.calculateContentHeight(size.height), 330);
    });

    test('accepts JSON and keeps an unknown width available to the parent', () {
      final size = TopIframeHelper.parseContentSize('{"height":180.5}');

      expect(size, isNotNull);
      expect(size!.width, isNull);
      expect(size.height, 180.5);
      expect(TopIframeHelper.calculateContentHeight(size.height), 181);
    });

    test('rejects malformed or non-finite dimensions from the web page', () {
      for (final message in [
        null,
        'not JSON',
        [],
        {'width': 320},
        {'height': 0},
        {'height': -1},
        {'height': double.nan},
        {'height': double.infinity},
        {'width': 0, 'height': 330},
        {'width': -320, 'height': 330},
        {'width': double.infinity, 'height': 330},
      ]) {
        expect(TopIframeHelper.parseContentSize(message), isNull);
      }
    });
  });

  test('updates when content shrinks as well as when it grows', () {
    expect(TopIframeHelper.shouldUpdateHeight(405, 330), isTrue);
    expect(TopIframeHelper.shouldUpdateHeight(330, 331), isTrue);
    expect(TopIframeHelper.shouldUpdateHeight(331, 330), isTrue);
    expect(TopIframeHelper.shouldUpdateHeight(330, 330), isFalse);
  });
}
