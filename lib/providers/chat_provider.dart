import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  final List<ConversationModel> _conversations = [];
  final List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<List<ConversationModel>> getConversations(String userId) {
    return _chatService.getConversations(userId);
  }

  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _chatService.getMessages(conversationId);
  }

  Future<void> sendMessage(String conversationId, String text, String senderId) async {
    try {
      await _chatService.sendMessage(conversationId, text, senderId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<String> startConversation(String userId, String driverId, String tripId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final conversationId = await _chatService.createConversation([userId, driverId], tripId);
      
      _isLoading = false;
      notifyListeners();
      return conversationId;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
