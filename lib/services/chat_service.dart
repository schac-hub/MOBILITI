import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ConversationModel>> getConversations(String userId) {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _db
        .collection('messages')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendMessage(String conversationId, String text, String senderId) async {
    final messageData = {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    final batch = _db.batch();
    
    final messageRef = _db.collection('messages').doc(conversationId).collection('messages').doc();
    batch.set(messageRef, messageData);
    
    final conversationRef = _db.collection('conversations').doc(conversationId);
    batch.update(conversationRef, {
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<String> createConversation(List<String> participants, String tripId) async {
    // Check if conversation already exists
    final existing = await _db
        .collection('conversations')
        .where('participants', arrayContains: participants[0])
        .where('tripId', isEqualTo: tripId)
        .get();
    
    for (var doc in existing.docs) {
      final parts = List<String>.from(doc.data()['participants']);
      if (parts.contains(participants[1])) {
        return doc.id;
      }
    }

    final docRef = _db.collection('conversations').doc();
    await docRef.set({
      'participants': participants,
      'tripId': tripId,
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }
}
