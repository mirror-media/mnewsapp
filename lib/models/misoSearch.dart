class MisoHybridSearchRequest {
  final String anonymousId;
  final String? userId;
  final String q;
  final String fq;

  final List<String>? facets;
  final int? snippetMaxChars;
  final List<String>? fl;
  final List<String>? exclude;
  final int? rows;
  final int? start;
  final String? orderBy; // 'relevance' | 'published_at'
  final bool? answer;

  final List<String>? sourceFl;
  final int? citeLink;
  final String? citeStart;
  final String? citeEnd;

  const MisoHybridSearchRequest({
    required this.anonymousId,
    this.userId,
    required this.q,
    required this.fq,
    this.facets,
    this.snippetMaxChars,
    this.fl,
    this.exclude,
    this.rows,
    this.start,
    this.orderBy,
    this.answer,
    this.sourceFl,
    this.citeLink,
    this.citeStart,
    this.citeEnd,
  });

  Map<String, dynamic> toJson() => {
    'anonymous_id': anonymousId,
    if (userId != null) 'user_id': userId,
    'q': q,
    'fq': fq,
    if (facets != null) 'facets': facets,
    if (snippetMaxChars != null) 'snippet_max_chars': snippetMaxChars,
    if (fl != null) 'fl': fl,
    if (exclude != null) 'exclude': exclude,
    if (rows != null) 'rows': rows,
    if (start != null) 'start': start,
    if (orderBy != null) 'order_by': orderBy,
    if (answer != null) 'answer': answer,
    if (sourceFl != null) 'source_fl': sourceFl,
    if (citeLink != null) 'cite_link': citeLink,
    if (citeStart != null) 'cite_start': citeStart,
    if (citeEnd != null) 'cite_end': citeEnd,
  };
}

class MisoHybridSearchResponse {
  final String message;
  final MisoHybridSearchData data;
  const MisoHybridSearchResponse({required this.message, required this.data});
  factory MisoHybridSearchResponse.fromJson(Map<String, dynamic> json) {
    return MisoHybridSearchResponse(
      message: (json['message'] ?? '').toString(),
      data: MisoHybridSearchData.fromJson((json['data'] ?? {}) as Map<String, dynamic>),
    );
  }
}

class MisoHybridSearchData {
  final String? misoId;
  final String? questionId;
  final int? took;
  final int? total;
  final List<MisoProductDoc> products;

  /// facets 原始資料：facet_fields -> key -> list
  final Map<String, dynamic>? facetCounts;

  const MisoHybridSearchData({
    required this.misoId,
    required this.questionId,
    required this.took,
    required this.total,
    required this.products,
    required this.facetCounts,
  });

  factory MisoHybridSearchData.fromJson(Map<String, dynamic> json) {
    final productsJson = (json['products'] as List?) ?? const [];
    return MisoHybridSearchData(
      misoId: json['miso_id']?.toString(),
      questionId: json['question_id']?.toString(),
      took: _asInt(json['took']),
      total: _asInt(json['total']),
      products: productsJson
          .whereType<Map>()
          .map((e) => MisoProductDoc.fromJson(e.cast<String, dynamic>()))
          .toList(),
      facetCounts: json['facet_counts'] is Map<String, dynamic>
          ? (json['facet_counts'] as Map<String, dynamic>)
          : null,
    );
  }

  List<MisoFacetBucket> parseFacetBuckets(String facetKey) {
    final facetFields = (facetCounts?['facet_fields'] as Map?)?.cast<String, dynamic>();
    final raw = facetFields?[facetKey];

    if (raw is List) {
      return raw
          .whereType<List>()
          .where((pair) => pair.length >= 2)
          .map((pair) => MisoFacetBucket(
        value: pair[0]?.toString() ?? '',
        count: _asInt(pair[1]) ?? 0,
      ))
          .where((b) => b.value.isNotEmpty)
          .toList();
    }

    return const [];
  }
}

class MisoFacetBucket {
  final String value;
  final int count;
  const MisoFacetBucket({required this.value, required this.count});
}

class MisoProductDoc {
  final String productId;
  final String? coverImage;
  final String? title;
  final String? publishedAt;
  final String? url;

  final String? snippet;
  final String? titleWithMarkups;
  final Map<String, dynamic>? customAttributes;

  const MisoProductDoc({
    required this.productId,
    this.coverImage,
    this.title,
    this.publishedAt,
    this.url,
    this.snippet,
    this.titleWithMarkups,
    this.customAttributes,
  });

  factory MisoProductDoc.fromJson(Map<String, dynamic> json) {
    return MisoProductDoc(
      productId: (json['product_id'] ?? '').toString(),
      coverImage: json['cover_image']?.toString(),
      title: json['title']?.toString(),
      publishedAt: json['published_at']?.toString(),
      url: json['url']?.toString(),
      snippet: json['snippet']?.toString(),
      titleWithMarkups: json['_title_with_markups']?.toString(),
      customAttributes: json['custom_attributes'] is Map<String, dynamic>
          ? (json['custom_attributes'] as Map<String, dynamic>)
          : null,
    );
  }

  String? get articleSection => customAttributes?['article:section']?.toString();
}

class MisoAnswerResponse {
  final String message;
  final MisoAnswerData data;

  const MisoAnswerResponse({required this.message, required this.data});

  factory MisoAnswerResponse.fromJson(Map<String, dynamic> json) {
    return MisoAnswerResponse(
      message: (json['message'] ?? '').toString(),
      data: MisoAnswerData.fromJson((json['data'] ?? {}) as Map<String, dynamic>),
    );
  }
}

class MisoAnswerData {
  final String? questionId;
  final String? status;
  final String? answer;
  final List<MisoAnswerSource> sources;

  const MisoAnswerData({
    required this.questionId,
    required this.status,
    required this.answer,
    required this.sources,
  });

  factory MisoAnswerData.fromJson(Map<String, dynamic> json) {
    final sourcesJson = (json['sources'] as List?) ?? const [];
    return MisoAnswerData(
      questionId: json['question_id']?.toString(),
      status: json['status']?.toString(),
      answer: json['answer']?.toString(),
      sources: sourcesJson
          .whereType<Map>()
          .map((e) => MisoAnswerSource.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }

  bool get isSuccess => status?.toLowerCase() == 'success';
  bool get isPending => status?.toLowerCase() == 'pending';
}

class MisoAnswerSource {
  final String? url;
  final String? title;

  const MisoAnswerSource({this.url, this.title});

  factory MisoAnswerSource.fromJson(Map<String, dynamic> json) {
    return MisoAnswerSource(
      url: json['url']?.toString(),
      title: json['title']?.toString(),
    );
  }
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}
