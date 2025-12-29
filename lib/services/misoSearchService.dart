import 'misoApiClient.dart';
import 'package:tv/models/misoSearch.dart';

class MisoSearchService {
  final MisoApiClient _client;
  final String anonymousId;
  final String? userId;

  MisoSearchService({
    required MisoApiClient client,
    required this.anonymousId,
    this.userId,
  }) : _client = client;

  /// ✅ 支援分頁：start/rows
  /// ✅ 支援排序：orderBy（relevance / published_at / -published_at）
  Future<MisoHybridSearchResponse> search(
      String q, {
        int start = 0,
        int rows = 20,
        String orderBy = 'relevance',
      }) {
    final request = MisoHybridSearchRequest(
      anonymousId: anonymousId,
      userId: userId,
      q: q,

      fq: 'product_id:/(mirrortv).+/',

      facets: const ['custom_attributes.article:section'],
      snippetMaxChars: 60,
      fl: const [
        'product_id',
        'cover_image',
        'url',
        'published_at',
        'title',
        'authors',
        'custom_attributes.*',
        'comments',
        'comment_count',
      ],
      exclude: const [
        'product_id_1',
        'product_id_2',
        'product_id_3',
      ],

      start: start,
      rows: rows,

      /// ✅ 可切換排序
      orderBy: orderBy,

      answer: true,
      sourceFl: const [
        'cover_image',
        'url',
        'created_at',
        'updated_at',
        'published_at',
        'title',
        'authors',
        'custom_attributes.*',
        'comments',
        'comment_count',
        'product_id',
      ],
      citeLink: 1,
      citeStart: '[',
      citeEnd: ']',
    );

    return _client.hybridSearch(request);
  }

  /// AI Answer（可選）
  Future<MisoAnswerResponse?> getAiAnswer(String questionId) {
    return _client.getAnswerWithProgress(questionId);
  }
}
