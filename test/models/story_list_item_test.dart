import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/storyListItem.dart';

void main() {
  setUp(() {
    Environment().initConfig(BuildFlavor.production);
  });

  group('StoryListItem thumbnail parsing', () {
    const imageUrl = 'https://statics.mnews.tw/images/video-cover.jpg';

    test('reads the URL string returned by the popular video feed', () {
      final story = StoryListItem.fromJson({
        'id': '254419',
        'slug': '20261004sot1753001',
        'name': '熱門影音',
        'heroImage': imageUrl,
        'source': 'yt',
      });

      expect(story.photoUrl, imageUrl);
    });

    test('trims whitespace around a thumbnail URL', () {
      final story = StoryListItem.fromJson({'heroImage': '  $imageUrl\n'});

      expect(story.photoUrl, imageUrl);
    });

    test('reads a video cover URL when the hero image is absent', () {
      final story = StoryListItem.fromJson({
        'heroVideo': {'coverPhoto': imageUrl},
      });

      expect(story.photoUrl, imageUrl);
    });

    test('keeps supporting GraphQL image objects and JSON strings', () {
      final imageApiData = {
        'w800': {'url': imageUrl},
      };
      for (final data in [imageApiData, jsonEncode(imageApiData)]) {
        final story = StoryListItem.fromJson({
          'heroImage': {'imageApiData': data},
        });

        expect(story.photoUrl, imageUrl);
      }
    });

    test('keeps supporting legacy image objects', () {
      final story = StoryListItem.fromJson({
        'heroImage': {'urlMobileSized': imageUrl},
      });

      expect(story.photoUrl, imageUrl);
    });

    test('falls back to the video cover for an invalid hero image string', () {
      for (final heroImage in ['', '   ', 'invalid-image']) {
        final story = StoryListItem.fromJson({
          'heroImage': heroImage,
          'heroVideo': {
            'coverPhoto': {'url': imageUrl},
          },
        });

        expect(story.photoUrl, imageUrl);
      }
    });

    test('uses the default when neither image is available', () {
      final story = StoryListItem.fromJson({'heroImage': null});

      expect(story.photoUrl, Environment().config.mirrorNewsDefaultImageUrl);
    });
  });
}
