class StudyGroup {
  final String groupId;
  final String creatorId;
  final String name;
  final String? description;
  final String? course;
  final String? subject;
  final String? campus;
  final int maxMembers;
  final bool isActive;
  final List<String> tags;
  final String creatorName;
  final int memberCount;
  final String? userRole;

  StudyGroup({
    required this.groupId,
    required this.creatorId,
    required this.name,
    this.description,
    this.course,
    this.subject,
    this.campus,
    this.maxMembers = 10,
    this.isActive = true,
    this.tags = const [],
    required this.creatorName,
    this.memberCount = 0,
    this.userRole,
  });

  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    return StudyGroup(
      groupId: json['group_id'],
      creatorId: json['creator_id'],
      name: json['name'],
      description: json['description'],
      course: json['course'],
      subject: json['subject'],
      campus: json['campus'],
      maxMembers: json['max_members'] ?? 10,
      isActive: json['is_active'] ?? true,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      creatorName: json['creator_name'] ?? '',
      memberCount: json['member_count'] ?? 0,
      userRole: json['user_role'],
    );
  }
}

class StudySession {
  final String sessionId;
  final String groupId;
  final String title;
  final String? location;
  final DateTime startTime;
  final DateTime? endTime;
  final String creatorName;

  StudySession({
    required this.sessionId,
    required this.groupId,
    required this.title,
    this.location,
    required this.startTime,
    this.endTime,
    required this.creatorName,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      sessionId: json['session_id'],
      groupId: json['group_id'],
      title: json['title'],
      location: json['location'],
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      creatorName: json['creator_name'] ?? '',
    );
  }
}
