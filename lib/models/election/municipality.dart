import 'package:tv/models/election/candidate.dart';

class Municipality {
  final String name;
  final String dataSource;
  final List<Candidate> candidates;

  const Municipality({
    required this.name,
    required this.candidates,
    required this.dataSource,
  });

  factory Municipality.fromJson(Map<String, dynamic> json) {
    List<Candidate> candidates = [];
    for (var item in json['candidates']) {
      candidates.add(Candidate.fromJson(item));
    }

    return Municipality(
      name: json['city'],
      candidates: candidates,
      dataSource: json['source'] ?? '鏡電視自行計票',
    );
  }
}
