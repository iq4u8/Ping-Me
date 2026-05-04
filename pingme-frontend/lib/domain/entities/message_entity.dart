class MessageEntity {
  final String id;
  final String content;
  final String senderId;
  final DateTime timestamp;
  final bool isMe;

  MessageEntity({
    required this.id,
    required this.content,
    required this.senderId,
    required this.timestamp,
    required this.isMe,
  });
}

class ConversationEntity {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastTimestamp;

  ConversationEntity({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastTimestamp,
  });
}
