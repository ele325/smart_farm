import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat_controller.dart';
import '../../widgets/chat_bubble.dart';

class ChatPage extends StatelessWidget {
  final ChatController controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RoboCare AI Assistant")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: controller.messagesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  reverse: true, // Pour voir les derniers messages en bas
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var m = snapshot.data![index];
                    return ChatBubble(message: m.text, isUser: m.sender == 'user');
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.textController,
              decoration: const InputDecoration(hintText: "Posez une question..."),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.green),
            onPressed: controller.sendMessage,
          ),
        ],
      ),
    );
  }
}