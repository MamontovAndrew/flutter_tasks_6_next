import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/support_chat_service.dart';
import './support_chat_screen.dart';

class AdminChatsListScreen extends StatefulWidget {
  const AdminChatsListScreen({super.key});

  @override
  State<AdminChatsListScreen> createState() => _AdminChatsListScreenState();
}

class _AdminChatsListScreenState extends State<AdminChatsListScreen> {
  late SupportChatService chatService;

  @override
  void initState() {
    super.initState();
    chatService = SupportChatService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Список чатов (Админ)"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: chatService.getAllChats(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Нет чатов"));
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final userId = docs[index].id;
              return ListTile(
                title: Text("Чат пользователя: $userId"),
                onTap: () {
                  // Переходим в экран чата с выбранным пользователем
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SupportChatScreen(companionId: userId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
