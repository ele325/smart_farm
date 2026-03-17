import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_message_model.dart';

class ChatController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // Stream pour écouter les messages en temps réel
  Stream<List<ChatMessage>> get messagesStream => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc.data()))
          .toList());

  void sendMessage() async {
    if (textController.text.trim().isEmpty) return;

    String msg = textController.text;
    textController.clear();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('messages')
        .add({
      'text': msg,
      'sender': 'user',
      'timestamp': FieldValue.serverTimestamp(),
    });
    // Ton script Python détectera cet ajout grâce au snapshot listener et répondra !
  }
}