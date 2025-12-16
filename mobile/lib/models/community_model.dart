class Community {
  final String communityId;
  final String name;
  final String? description;
  final String? category;
  final String? campus;
  final String? icon;
  final bool isActive;
  final int memberCount;
  final String? userRole;

  Community({
    required this.communityId,
    required this.name,
    this.description,
    this.category,
    this.campus,
    this.icon,
    this.isActive = true,
    this.memberCount = 0,
    this.userRole,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      communityId: json['community_id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      campus: json['campus'],
      icon: json['icon'],
      isActive: json['is_active'] ?? true,
      memberCount: json['member_count'] ?? 0,
      userRole: json['user_role'],
    );
  }
}

class CommunityPost {
  final String postId;
  final String communityId;
  final String userId;
  final String content;
  final String? mediaUrl;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final String username;
  final String? avatarUrl;
  final bool userLiked;

  CommunityPost({
    required this.postId,
    required this.communityId,
    required this.userId,
    required this.content,
    this.mediaUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    required this.username,
    this.avatarUrl,
    this.userLiked = false,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      postId: json['post_id'],
      communityId: json['community_id'],
      userId: json['user_id'],
      content: json['content'],
      mediaUrl: json['media_url'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      username: json['username'] ?? '',
      avatarUrl: json['avatar_url'],
      userLiked: json['user_liked'] ?? false,
    );
  }
}
