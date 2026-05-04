import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<List<ConversationEntity>> getConversations();
  Future<List<MessageEntity>> getMessages(String conversationId);
  Future<void> sendMessage(String conversationId, String content);
}
