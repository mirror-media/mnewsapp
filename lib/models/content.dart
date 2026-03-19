import 'package:tv/models/baseModel.dart';

class Content {
  String data;
  double? aspectRatio;
  String? description;

  Content({
    required this.data,
    required this.aspectRatio,
    required this.description,
  });

  factory Content.fromJson(dynamic json) {
    print('[Content.fromJson] runtimeType = ${json.runtimeType}');
    print('[Content.fromJson] raw = $json');

    if (json == null) {
      print('[Content.fromJson] -> null branch');
      return Content(
        data: '',
        aspectRatio: null,
        description: null,
      );
    }

    if (json is String) {
      print('[Content.fromJson] -> string branch');
      return Content(
        data: json,
        aspectRatio: null,
        description: null,
      );
    }

    if (json is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(json);

      print('[Content.fromJson] map keys = ${map.keys.toList()}');

      // ---------- V2 wrapper support ----------
      // slideshow-v2 / AUDIO-V2 / VIDEO-V2 可能包在 data 裡
      if (map['data'] is Map) {
        final innerData = Map<String, dynamic>.from(map['data']);

        if (map['type'] == 'slideshow-v2' || map['type'] == 'SLIDESHOW-V2') {
          print('[Content.fromJson] -> slideshow-v2 wrapper branch');
          return Content(
            data: '',
            aspectRatio: null,
            description: null,
          );
        }

        if (map['type'] == 'AUDIO-V2') {
          final audio = innerData['audio'];
          if (audio is Map) {
            final audioMap = Map<String, dynamic>.from(audio);
            print('[Content.fromJson] -> AUDIO-V2 wrapper branch');
            return Content(
              data: audioMap['url']?.toString() ?? '',
              aspectRatio: null,
              description: audioMap['name']?.toString(),
            );
          }
        }

        if (map['type'] == 'VIDEO-V2') {
          final video = innerData['video'];
          if (video is Map) {
            final videoMap = Map<String, dynamic>.from(video);
            print('[Content.fromJson] -> VIDEO-V2 wrapper branch');
            return Content(
              data: _extractVideoUrl(videoMap) ?? '',
              aspectRatio: null,
              description:
              innerData['desc']?.toString() ?? videoMap['name']?.toString(),
            );
          }
        }
      }

      // ---------- image ----------
      if (map.containsKey('resized') ||
          map.containsKey('resizedWebp') ||
          map.containsKey('file')) {
        final imageUrl = _extractImageUrl(map);
        final ratio = _extractAspectRatioFromFile(map['file']);
        final desc = _extractDescription(map);

        print('[Content.fromJson] -> image branch');
        print('[Content.fromJson] extracted imageUrl = $imageUrl');
        print('[Content.fromJson] extracted desc = $desc');
        print('[Content.fromJson] extracted ratio = $ratio');

        return Content(
          data: imageUrl ?? '',
          aspectRatio: ratio,
          description: desc,
        );
      }

      // ---------- old mobile image ----------
      if (BaseModel.checkJsonKeys(map, ['mobile'])) {
        print('[Content.fromJson] -> mobile branch');
        final mobile = map['mobile'];
        if (mobile is Map) {
          final mobileMap = Map<String, dynamic>.from(mobile);

          final width = mobileMap['width'];
          final height = mobileMap['height'];

          double? ratio;
          if (width is num && height is num && height != 0) {
            ratio = width / height;
          }

          return Content(
            data: mobileMap['url']?.toString() ?? '',
            aspectRatio: ratio,
            description: map['title']?.toString(),
          );
        }
      }

      // ---------- youtube ----------
      if (BaseModel.checkJsonKeys(map, ['youtubeId'])) {
        print('[Content.fromJson] -> youtube branch');
        return Content(
          data: map['youtubeId']?.toString() ?? '',
          aspectRatio: null,
          description: map['description']?.toString(),
        );
      }

      // ---------- audio (flattened K6) ----------
      if (BaseModel.checkJsonKeys(map, ['audio'])) {
        final audio = map['audio'];
        if (audio is Map) {
          final audioMap = Map<String, dynamic>.from(audio);
          print('[Content.fromJson] -> audio branch');
          return Content(
            data: audioMap['url']?.toString() ?? '',
            aspectRatio: null,
            description: audioMap['name']?.toString(),
          );
        }
      }

      // ---------- video (flattened K6) ----------
      if (BaseModel.checkJsonKeys(map, ['video'])) {
        final video = map['video'];
        if (video is Map) {
          final videoMap = Map<String, dynamic>.from(video);
          print('[Content.fromJson] -> video branch');
          return Content(
            data: _extractVideoUrl(videoMap) ?? '',
            aspectRatio: null,
            description:
            map['desc']?.toString() ?? videoMap['name']?.toString(),
          );
        }
      }

      // ---------- slideshow flattened container ----------
      if (BaseModel.checkJsonKeys(map, ['images'])) {
        final images = map['images'];
        if (images is List && images.isNotEmpty) {
          final first = images.first;
          if (first is Map) {
            final firstMap = Map<String, dynamic>.from(first);
            print('[Content.fromJson] -> slideshow images container branch');
            return Content(
              data: _extractImageUrl(firstMap) ?? '',
              aspectRatio: _extractAspectRatioFromFile(firstMap['file']),
              description: _extractDescription(firstMap),
            );
          }
        }
      }

      // ---------- direct url ----------
      if (BaseModel.checkJsonKeys(map, ['url'])) {
        print('[Content.fromJson] -> url branch');
        return Content(
          data: map['url']?.toString() ?? '',
          aspectRatio: null,
          description: map['name']?.toString(),
        );
      }

      // ---------- embedded code ----------
      if (BaseModel.checkJsonKeys(map, ['embeddedCode'])) {
        print('[Content.fromJson] -> embeddedCode branch');
        double? ratio;
        if (map['width'] != null && map['height'] != null) {
          final width = double.tryParse(map['width'].toString());
          final height = double.tryParse(map['height'].toString());
          if (width != null && height != null && height != 0) {
            ratio = width / height;
          }
        }

        return Content(
          data: map['embeddedCode']?.toString() ?? '',
          aspectRatio: ratio,
          description: map['caption']?.toString(),
        );
      }

      // ---------- title/body ----------
      if (BaseModel.checkJsonKeys(map, ['draftRawObj']) ||
          BaseModel.checkJsonKeys(map, ['title'])) {
        print('[Content.fromJson] -> title/body branch');
        return Content(
          data: map['body']?.toString() ?? '',
          aspectRatio: null,
          description: map['title']?.toString(),
        );
      }

      // ---------- quote ----------
      if (BaseModel.checkJsonKeys(map, ['quote'])) {
        print('[Content.fromJson] -> quote branch');
        return Content(
          data: map['quote']?.toString() ?? '',
          aspectRatio: null,
          description: map['quoteBy']?.toString(),
        );
      }

      // ---------- generic data fallback ----------
      if (map['data'] != null && map['data'] is! Map) {
        print('[Content.fromJson] -> data fallback branch');
        return Content(
          data: map['data']?.toString() ?? '',
          aspectRatio: null,
          description: map['description']?.toString(),
        );
      }

      print('[Content.fromJson] -> map.toString fallback branch');
      return Content(
        data: map.toString(),
        aspectRatio: null,
        description: null,
      );
    }

    print('[Content.fromJson] -> final fallback branch');
    return Content(
      data: json.toString(),
      aspectRatio: null,
      description: null,
    );
  }

  static String? _extractImageUrl(Map<String, dynamic> map) {
    final resized = map['resized'];
    if (resized is Map) {
      final resizedMap = Map<String, dynamic>.from(resized);
      for (final key in ['w800', 'w480', 'original', 'w1200', 'w1600', 'w2400']) {
        final value = resizedMap[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    final resizedWebp = map['resizedWebp'];
    if (resizedWebp is Map) {
      final resizedWebpMap = Map<String, dynamic>.from(resizedWebp);
      for (final key in ['w800', 'w480', 'original', 'w1200', 'w1600', 'w2400']) {
        final value = resizedWebpMap[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    final file = map['file'];
    if (file is Map) {
      final fileMap = Map<String, dynamic>.from(file);
      final fileUrl = fileMap['url'];
      if (fileUrl is String && fileUrl.isNotEmpty) {
        return fileUrl;
      }
    }

    final directUrl = map['url'];
    if (directUrl is String && directUrl.isNotEmpty) {
      return directUrl;
    }

    return null;
  }

  static String? _extractVideoUrl(Map<String, dynamic> map) {
    final videoSrc = map['videoSrc'];
    if (videoSrc is String && videoSrc.isNotEmpty) {
      return videoSrc;
    }

    final url = map['url'];
    if (url is String && url.isNotEmpty) {
      return url;
    }

    final file = map['file'];
    if (file is Map) {
      final fileMap = Map<String, dynamic>.from(file);
      final fileUrl = fileMap['url'];
      if (fileUrl is String && fileUrl.isNotEmpty) {
        return fileUrl;
      }
    }

    return null;
  }

  static double? _extractAspectRatioFromFile(dynamic file) {
    if (file is! Map) return null;

    final fileMap = Map<String, dynamic>.from(file);
    final width = fileMap['width'];
    final height = fileMap['height'];

    if (width is num && height is num && height != 0) {
      return width / height;
    }

    return null;
  }

  static String? _extractDescription(Map<String, dynamic> map) {
    final desc = map['desc'];
    if (desc is String && desc.isNotEmpty) return desc;

    final title = map['title'];
    if (title is String && title.isNotEmpty) return title;

    final name = map['name'];
    if (name is String && name.isNotEmpty) return name;

    return null;
  }
}