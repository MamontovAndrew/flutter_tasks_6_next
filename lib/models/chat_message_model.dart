import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String text;
  final String senderId;
  final String receiverId;
  final DateTime createdAt;

  ChatMessageModel({
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
  });

  static ChatMessageModel fromSnapshot(QueryDocumentSnapshot<Object?> snapshot) {
    return ChatMessageModel(
      text: snapshot['text'],
      senderId: snapshot['senderId'],
      receiverId: snapshot['receiverId'],
      createdAt: snapshot['createdAt'].toDate(),
    );
  }
}
