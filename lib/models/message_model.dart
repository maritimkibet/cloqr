class Message {
  final String messageId;
  final String chatId;
  final String senderId;
  final String content;
  final String type;
  final bool isOneTime;
  final List<String> viewedBy;
  final DateTime expiresAt;
  final DateTime createdAt;
  final MessageUser? user;

  Message({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.isOneTime,
    required this.viewedBy,
    required this.expiresAt,
    required this.createdAt,
    this.user,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['message_id'],
      chatId: json['chat_id'],
      senderId: json['sender_id'],
      content: json['content'],
      type: json['type'] ?? 'text',
      isOneTime: json['is_one_time'] ?? false,
      viewedBy: json['viewed_by'] != null 
          ? List<String>.from(json['viewed_by']) 
          : [],
      expiresAt: DateTime.parse(json['expires_at']),
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'] != null ? MessageUser.fromJson(json['user']) : null,
    );
  }
}

class MessageUser {
  final String userId;
  final String username;
  final String? avatarUrl;

  MessageUser({
    required this.userId,
    required this.username,
    this.avatarUrl,
  });

  factory MessageUser.fromJson(Map<String, dynamic> json) {
    return MessageUser(
      userId: json['user_id'],
      username: json['username'],
      avatarUrl: json['avatar_url'],
    );
  }
}

class Chat {
  final String chatId;
  final String type;
  final String? name;
  final DateTime? expiresAt;
  final List<MessageUser> members;

  Chat({
    required this.chatId,
    required this.type,
    this.name,
    this.expiresAt,
    required this.members,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      chatId: json['chat_id'],
      type: json['type'],
      name: json['name'],
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at']) 
          : null,
      members: (json['members'] as List)
          .map((m) => MessageUser.fromJson(m))
          .toList(),
    );
  }
}
