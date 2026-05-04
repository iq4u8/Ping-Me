import 'package:flutter/material.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository;

  ChatViewModel(this._repository);

  List<ConversationEntity> _conversations = [];
  List<ConversationEntity> get conversations => _conversations;

  List<MessageEntity> _currentMessages = [];
  List<MessageEntity> get currentMessages => _currentMessages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<String> _folders = ['Unread', 'Favourites', 'Groups'];
  List<String> get folders => _folders;

  void addFolder(String name) {
    if (name.isNotEmpty && !_folders.contains(name)) {
      _folders.add(name);
      notifyListeners();
    }
  }

  void renameFolder(int index, String newName) {
    if (newName.isNotEmpty && index >= 0 && index < _folders.length) {
      _folders[index] = newName;
      notifyListeners();
    }
  }

  void removeFolder(int index) {
    if (index >= 0 && index < _folders.length) {
      _folders.removeAt(index);
      notifyListeners();
    }
  }

  void reorderFolders(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _folders.removeAt(oldIndex);
    _folders.insert(newIndex, item);
    notifyListeners();
  }

  Future<void> loadConversations() async {
    _isLoading = true;
    _conversations = await _repository.getConversations();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMessages(String convId) async {
    _isLoading = true;
    _currentMessages = await _repository.getMessages(convId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> send(String convId, String text) async {
    final newMessage = MessageEntity(
      id: DateTime.now().toString(),
      content: text,
      senderId: "me",
      timestamp: DateTime.now(),
      isMe: true,
    );
    _currentMessages.add(newMessage);
    notifyListeners();
    await _repository.sendMessage(convId, text);
  }
}
