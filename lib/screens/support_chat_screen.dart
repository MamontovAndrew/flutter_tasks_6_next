import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/support_chat_service.dart';
import '../services/user_service.dart';
import '../models/chat_message_model.dart';

class SupportChatScreen extends StatefulWidget {
  final String companionId;

  const SupportChatScreen({
    Key? key,
    required this.companionId,
  }) : super(key: key);

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  late final SupportChatService chatService;
  late final UserService userService;
  final TextEditingController _controller = TextEditingController();

  bool _isAdmin = false; // Флаг для админа
  bool _isLoading = true; // Индикатор загрузки

  @override
  void initState() {
    super.initState();
    chatService = SupportChatService();
    userService = UserService();

    _initAdminCheck();
  }

  Future<void> _initAdminCheck() async {
    final bool adminFlag = await userService.isAdmin();
    setState(() {
      _isAdmin = adminFlag;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Пока не определили роль пользователя
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Чат")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isAdmin
              ? "Чат с пользователем ${widget.companionId}"
              : "Поддержка",
        ),
      ),
      body: Column(
        children: [
          // Список сообщений
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: chatService.getMessagesStream(widget.companionId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Нет сообщений"));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final text = data['text'] ?? "";
                    final senderId = data['senderId'] ?? "";
                    final receiverId = data['receiverId'] ?? "";
                    final Timestamp? ts = data['createdAt'] as Timestamp?;
                    final dateTime = ts?.toDate();

                    final bool isMyMessage =
                    (senderId == userService.getCurrentUserId());

                    return _buildMessageBubble(
                      text: text,
                      isMyMessage: isMyMessage,
                      dateTime: dateTime,
                    );
                  },
                );
              },
            ),
          ),
          // Поле ввода сообщения
          _buildInputRow(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required bool isMyMessage,
    required DateTime? dateTime,
  }) {
    final alignment =
    isMyMessage ? Alignment.centerRight : Alignment.centerLeft;
    final crossAxisAlign =
    isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMyMessage ? Colors.blue[100] : Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: crossAxisAlign,
        children: [
          Text(text, style: const TextStyle(fontSize: 16)),
          if (dateTime != null)
            Text(
              "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
        ],
      ),
    );
  }

  Widget _buildInputRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: "Введите сообщение...",
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () async {
            final text = _controller.text.trim();
            if (text.isEmpty) return;
            _controller.clear();

            // Формируем модель сообщения
            final ChatMessageModel msg = ChatMessageModel(
              text: text,
              senderId: userService.getCurrentUserId() ?? "",
              receiverId: widget.companionId,
              createdAt: DateTime.now(),
            );

            try {
              await chatService.sendMessage(msg);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Ошибка при отправке: $e")),
              );
            }
          },
        ),
      ],
    );
  }
}
