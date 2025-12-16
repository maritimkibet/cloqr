class Event {
  final String eventId;
  final String creatorId;
  final String title;
  final String? description;
  final String? eventType;
  final String? location;
  final String? campus;
  final DateTime startTime;
  final DateTime? endTime;
  final int? maxAttendees;
  final bool isPublic;
  final List<String> tags;
  final String creatorName;
  final int attendeeCount;
  final String? userStatus;

  Event({
    required this.eventId,
    required this.creatorId,
    required this.title,
    this.description,
    this.eventType,
    this.location,
    this.campus,
    required this.startTime,
    this.endTime,
    this.maxAttendees,
    this.isPublic = true,
    this.tags = const [],
    required this.creatorName,
    this.attendeeCount = 0,
    this.userStatus,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['event_id'],
      creatorId: json['creator_id'],
      title: json['title'],
      description: json['description'],
      eventType: json['event_type'],
      location: json['location'],
      campus: json['campus'],
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      maxAttendees: json['max_attendees'],
      isPublic: json['is_public'] ?? true,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      creatorName: json['creator_name'] ?? '',
      attendeeCount: json['attendee_count'] ?? 0,
      userStatus: json['user_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'creator_id': creatorId,
      'title': title,
      'description': description,
      'event_type': eventType,
      'location': location,
      'campus': campus,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'max_attendees': maxAttendees,
      'is_public': isPublic,
      'tags': tags,
    };
  }
}
