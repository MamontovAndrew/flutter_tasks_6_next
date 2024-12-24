import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import './user_service.dart';
import '../models/chat_message_model.dart';

/// Сервис, который умеет отправлять и получать сообщения чата
/// между админом и пользователем.
class SupportChatService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService userService = UserService();

  /// Отправка сообщения (общая логика для админа и простого пользователя).
  /// - Если пользователь не админ, то получателем должен быть adminId.
  /// - Если пользователь админ, то получателем остаётся [message.receiverId].
  /// - Сами сообщения храним в коллекции `chats/{chatDocId}/messages`.
  ///   Где `chatDocId` либо userId (если мы админ),
  ///   либо текущий userId (если мы обычный пользователь).
  Future<void> sendMessage(ChatMessageModel message) async {
    final currentUserId = userService.getCurrentUserId();
    if (currentUserId == null) {
      throw Exception("Пользователь не аутентифицирован");
    }

    final isCurrentAdmin = await userService.isAdmin();
    final adminId = await userService.getAdminId(); // Считаем, что админ только один.

    // Если текущий не админ, значит отправляем админу
    String receiverId = isCurrentAdmin ? message.receiverId : adminId;

    // В каком документе Firestore сохраняем чат:
    // - если админ, то документы хранятся по userId (message.receiverId).
    // - если user, то документы хранятся по currentUserId.
    final chatDocId = isCurrentAdmin ? message.receiverId : currentUserId;

    // Ссылка на документ чата
    final chatDocRef = _firestore.collection("chats").doc(chatDocId);

    // Проверяем, существует ли документ чата
    final chatDoc = await chatDocRef.get();
    if (!chatDoc.exists) {
      // Создаём документ чата с начальной информацией
      await chatDocRef.set({
        'createdAt': Timestamp.now(),
        'participants': isCurrentAdmin
            ? [currentUserId, receiverId]
            : [currentUserId, adminId],
        // Добавьте другие метаданные чата, если необходимо
      });
    }

    // Теперь добавляем сообщение в коллекцию сообщений
    await chatDocRef.collection("messages").add({
      'text': message.text,
      'createdAt': Timestamp.fromDate(message.createdAt),
      'senderId': currentUserId,
      'receiverId': receiverId,
    });
  }

  /// Получение списка всех чатов (для админа, чтобы увидеть всех пользователей).
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllChats() {
    // В данной структуре у нас `chats` - это коллекция документов,
    // каждый документ называется userId. Внутри - коллекция messages.
    return _firestore.collection("chats").snapshots();
  }

  /// Получение потока сообщений чата:
  /// - Если admin, читаем чат из doc(companionId).
  /// - Если user, читаем чат из doc(текущий userId).
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessagesStream(
      String companionId,
      ) async* {
    final currentUserId = userService.getCurrentUserId();
    if (currentUserId == null) {
      throw Exception("Пользователь не аутентифицирован");
    }
    final isCurrentAdmin = await userService.isAdmin();

    final chatDocId = isCurrentAdmin ? companionId : currentUserId;

    yield* _firestore
        .collection("chats")
        .doc(chatDocId)
        .collection("messages")
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
