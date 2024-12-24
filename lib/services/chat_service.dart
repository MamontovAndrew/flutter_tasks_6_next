import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_service.dart';
import '../models/chat_message_model.dart';

class ChatService {
  final FirebaseFirestore firestore;
  final UserService userService;

  ChatService(this.userService) : firestore = FirebaseFirestore.instance;

  Future<void> sendMessage({
    required String text,
    required String receiverId,
  }) async {
    final senderId = userService.getCurrentUserId();
    if (senderId == null) {
      throw Exception("Пользователь не аутентифицирован");
    }

    await firestore.collection('chats').doc(senderId).collection('messages').add({
      'text': text,
      'createdAt': Timestamp.now(),
      'senderId': senderId,
      'receiverId': receiverId,
    });
  }

  Stream<List<ChatMessageModel>> getMessagesStream(String companionId) {
    final userId = userService.getCurrentUserId();
    if (userId == null) {
      throw Exception("Пользователь не аутентифицирован");
    }

    return firestore
        .collection('chats')
        .doc(userId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      return ChatMessageModel.fromSnapshot(doc);
    }).toList());
  }

  Stream<List<String>> getAllChats() {
    return firestore.collection('chats').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }
}
