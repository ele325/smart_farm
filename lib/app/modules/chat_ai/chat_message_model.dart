import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String text;
  final String sender; // 'user' ou 'ai'
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  factory ChatMessage.fromFirestore(Map<String, dynamic> data) {
    return ChatMessage(
      text: data['text'] ?? '',
      sender: data['sender'] ?? 'ai',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
