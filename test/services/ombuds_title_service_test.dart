import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/services/ombuds_title_service.dart';

http.Response _htmlResponse(String html, {int statusCode = 200}) =>
    http.Response.bytes(
      utf8.encode(html),
      statusCode,
      headers: {'content-type': 'text/html'},
    );

class _TrackingClient extends MockClient {
  _TrackingClient(super.handler);

  bool closed = false;

  @override
  void close() {
    closed = true;
    super.close();
  }
}

void main() {
  setUp(() {
    Environment().initConfig(BuildFlavor.production);
  });

  for (final title in ['外部公評人莊豐嘉', '外部公評人陳新任']) {
    test('fetches the configured web page heading: $title', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url, Uri.parse(Environment().config.ombudsAppealUrl));
        return _htmlResponse('<html><body><h1>$title</h1></body></html>');
      });
      addTearDown(client.close);

      expect(await OmbudsTitleService(client: client).fetchTitle(), title);
    });
  }

  test('decodes UTF-8, nested tags and entities in the matching h1', () async {
    final client = MockClient(
      (_) async => _htmlResponse('''
      <h1>鏡新聞</h1>
      <h1> \n 外部公評人<span>莊&#35920;嘉</span> \n </h1>
      <h2>外部公評人其他姓名</h2>
    '''),
    );
    addTearDown(client.close);

    expect(await OmbudsTitleService(client: client).fetchTitle(), '外部公評人莊豐嘉');
  });

  for (final html in [
    '<h2>外部公評人莊豐嘉</h2>',
    '<h1>外部公評人&nbsp; \n </h1>',
    '<h1>公評人介紹</h1>',
  ]) {
    test('returns no title when a valid named h1 is absent: $html', () async {
      final client = MockClient((_) async => _htmlResponse(html));
      addTearDown(client.close);

      expect(await OmbudsTitleService(client: client).fetchTitle(), isNull);
    });
  }

  test('rejects an unsuccessful HTTP response', () async {
    final client = MockClient(
      (_) async => _htmlResponse('<h1>外部公評人莊豐嘉</h1>', statusCode: 503),
    );
    addTearDown(client.close);

    await expectLater(
      OmbudsTitleService(client: client).fetchTitle(),
      throwsA(isA<http.ClientException>()),
    );
  });

  test('propagates a network failure', () async {
    final failure = http.ClientException('offline');
    final client = MockClient((_) async => throw failure);
    addTearDown(client.close);

    await expectLater(
      OmbudsTitleService(client: client).fetchTitle(),
      throwsA(same(failure)),
    );
  });

  test('times out a stalled web request', () async {
    final response = Completer<http.Response>();
    final client = MockClient((_) => response.future);
    addTearDown(client.close);

    await expectLater(
      OmbudsTitleService(
        client: client,
        timeout: const Duration(milliseconds: 10),
      ).fetchTitle(),
      throwsA(isA<TimeoutException>()),
    );
    response.complete(_htmlResponse('<h1>外部公評人莊豐嘉</h1>'));
  });

  test('keeps an injected client open after success and failure', () async {
    var requests = 0;
    final client = _TrackingClient((_) async {
      requests++;
      return _htmlResponse(
        '<h1>外部公評人莊豐嘉</h1>',
        statusCode: requests == 1 ? 200 : 500,
      );
    });
    addTearDown(client.close);
    final service = OmbudsTitleService(client: client);

    expect(await service.fetchTitle(), '外部公評人莊豐嘉');
    expect(client.closed, isFalse);
    await expectLater(
      service.fetchTitle(),
      throwsA(isA<http.ClientException>()),
    );
    expect(client.closed, isFalse);
  });

  test('creates and closes an owned client for each fetch', () async {
    final clients = <_TrackingClient>[];
    await http.runWithClient(
      () async {
        final service = OmbudsTitleService();

        expect(await service.fetchTitle(), '外部公評人莊豐嘉');
        expect(clients.single.closed, isTrue);
        await expectLater(
          service.fetchTitle(),
          throwsA(isA<http.ClientException>()),
        );
      },
      () {
        final statusCode = clients.isEmpty ? 200 : 503;
        final client = _TrackingClient(
          (_) async =>
              _htmlResponse('<h1>外部公評人莊豐嘉</h1>', statusCode: statusCode),
        );
        clients.add(client);
        return client;
      },
    );

    expect(clients, hasLength(2));
    expect(clients.every((client) => client.closed), isTrue);
  });
}
