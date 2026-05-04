import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  @override
  Future<List<ConversationEntity>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      ConversationEntity(
        id: "1",
        name: "NODE_ALPHA",
        lastMessage: "SIGNAL_SECURED",
        lastTimestamp: DateTime.now(),
      ),
      ConversationEntity(
        id: "2",
        name: "NODE_BETA",
        lastMessage: "ACK_RECEIVED",
        lastTimestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  @override
  Future<List<MessageEntity>> getMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      MessageEntity(
        id: "m1",
        content: "ESTABLISHING_TUNNEL...",
        senderId: "other",
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isMe: false,
      ),
      MessageEntity(
        id: "m2",
        content: "TUNNEL_READY",
        senderId: "me",
        timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
        isMe: true,
      ),
    ];
  }

  @override
  Future<void> sendMessage(String conversationId, String content) async {
    // 3.1.2 Send Message logic
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
