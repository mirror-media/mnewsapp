import 'package:flutter_test/flutter_test.dart';
import 'package:tv/helpers/notification_deep_link_parser.dart';

void main() {
  group('NotificationDeepLinkParser.extractStorySlug', () {
    test('extracts the legacy news story slug key', () {
      final slug = NotificationDeepLinkParser.extractStorySlug({
        'news_story_slug': 'sample-story',
      });

      expect(slug, 'sample-story');
    });

    test('extracts common camelCase slug keys', () {
      final slug = NotificationDeepLinkParser.extractStorySlug({
        'storySlug': 'camel-case-story',
      });

      expect(slug, 'camel-case-story');
    });

    test('extracts slug from a website story URL', () {
      final slug = NotificationDeepLinkParser.extractStorySlug({
        'url': 'https://www.mnews.tw/story/article-slug?utm_source=fcm',
      });

      expect(slug, 'article-slug');
    });

    test('extracts slug from an app deep link', () {
      final slug = NotificationDeepLinkParser.extractStorySlug({
        'deepLink': 'mnews://story/deep-link-story',
      });

      expect(slug, 'deep-link-story');
    });

    test('extracts slug from a JSON payload string', () {
      final slug = NotificationDeepLinkParser.extractStorySlug({
        'payload': '{"story_url":"https://www.mnews.tw/story/json-story"}',
      });

      expect(slug, 'json-story');
    });
  });
}
