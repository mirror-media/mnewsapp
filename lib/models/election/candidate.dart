class Candidate {
  final String number;
  final String name;
  final String party;
  final int votes;
  final double percentageOfVotesObtained;
  final bool elected;

  const Candidate({
    required this.number,
    required this.name,
    this.party = '無黨籍',
    this.votes = 0,
    this.percentageOfVotesObtained = 0.0,
    this.elected = false,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      number: json['candNo'],
      name: json['name'],
      party: json['party'],
      votes: json['tks'],
      percentageOfVotesObtained: json['tksRate'].toDouble(),
      elected: json['candVictor'],
    );
  }
}
