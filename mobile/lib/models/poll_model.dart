class Poll {
  final String pollId;
  final String creatorId;
  final String question;
  final List<String> options;
  final String? campus;
  final DateTime? expiresAt;
  final bool isActive;
  final String creatorName;
  final int totalVotes;
  final int? userVote;
  final List<VoteCount> voteCounts;

  Poll({
    required this.pollId,
    required this.creatorId,
    required this.question,
    required this.options,
    this.campus,
    this.expiresAt,
    this.isActive = true,
    required this.creatorName,
    this.totalVotes = 0,
    this.userVote,
    this.voteCounts = const [],
  });

  factory Poll.fromJson(Map<String, dynamic> json) {
    List<VoteCount> counts = [];
    if (json['vote_counts'] != null) {
      counts = (json['vote_counts'] as List)
          .map((v) => VoteCount.fromJson(v))
          .toList();
    }

    return Poll(
      pollId: json['poll_id'],
      creatorId: json['creator_id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      campus: json['campus'],
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      isActive: json['is_active'] ?? true,
      creatorName: json['creator_name'] ?? '',
      totalVotes: json['total_votes'] ?? 0,
      userVote: json['user_vote'],
      voteCounts: counts,
    );
  }
}

class VoteCount {
  final int optionIndex;
  final int count;

  VoteCount({required this.optionIndex, required this.count});

  factory VoteCount.fromJson(Map<String, dynamic> json) {
    return VoteCount(
      optionIndex: json['option_index'],
      count: int.parse(json['count'].toString()),
    );
  }
}
