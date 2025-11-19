class User {
  final String userId;
  final String username;
  final String campus;
  final String? avatarUrl;
  final String? blurredPhotoUrl;
  final String mode;
  final int trustScore;

  User({
    required this.userId,
    required this.username,
    required this.campus,
    this.avatarUrl,
    this.blurredPhotoUrl,
    required this.mode,
    required this.trustScore,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      username: json['username'],
      campus: json['campus'],
      avatarUrl: json['avatar_url'],
      blurredPhotoUrl: json['blurred_photo_url'],
      mode: json['mode'] ?? 'dating',
      trustScore: json['trust_score'] ?? 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'campus': campus,
      'avatar_url': avatarUrl,
      'blurred_photo_url': blurredPhotoUrl,
      'mode': mode,
      'trust_score': trustScore,
    };
  }
}

class Profile {
  final String profileId;
  final String userId;
  final int? year;
  final String? course;
  final String? bio;
  final List<String>? interests;
  final String? studyStyle;
  final String? studyTime;
  final List<String>? hobbies;

  Profile({
    required this.profileId,
    required this.userId,
    this.year,
    this.course,
    this.bio,
    this.interests,
    this.studyStyle,
    this.studyTime,
    this.hobbies,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      profileId: json['profile_id'],
      userId: json['user_id'],
      year: json['year'],
      course: json['course'],
      bio: json['bio'],
      interests: json['interests'] != null 
          ? List<String>.from(json['interests']) 
          : null,
      studyStyle: json['study_style'],
      studyTime: json['study_time'],
      hobbies: json['hobbies'] != null 
          ? List<String>.from(json['hobbies']) 
          : null,
    );
  }
}
