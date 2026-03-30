import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'chat_message_model.dart';

class ChatController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();

  String get uid => FirebaseAuth.instance.currentUser?.uid ?? "guest_user";

  final RxString currentChatId = ''.obs;
  final RxBool isListening = false.obs;
  final RxString recognizedText = ''.obs;
  final RxBool speechAvailable = false.obs;

  // ── État de l'IA : null | 'thinking' | 'replying' ──
  final RxnString aiState = RxnString(null);

  // ── Langue micro ──
  final RxString selectedLocale = 'ar_SA'.obs;

  static const Map<String, String> localeLabels = {
    'ar_SA': '🇸🇦 عربي',
    'fr_FR': '🇫🇷 Français',
    'en_US': '🇬🇧 English',
  };

  // Textes multilingues pour les états de l'IA
  Map<String, Map<String, String>> get _stateLabels => {
    'ar_SA': {
      'thinking': '🤔 جارٍ التفكير...',
      'replying': '✍️ جارٍ الرد...',
      'listening': '🎤 الاستماع جارٍ...',
    },
    'fr_FR': {
      'thinking': '🤔 En réflexion...',
      'replying': '✍️ Rédaction en cours...',
      'listening': '🎤 Écoute en cours...',
    },
    'en_US': {
      'thinking': '🤔 Thinking...',
      'replying': '✍️ Replying...',
      'listening': '🎤 Listening...',
    },
  };

  String getStateLabel(String key) {
    return _stateLabels[selectedLocale.value]?[key] ?? '...';
  }

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
    startNewChat();
  }

  // =========================================================
  // SESSIONS
  // =========================================================

  void startNewChat() {
    currentChatId.value = DateTime.now().millisecondsSinceEpoch.toString();
    textController.clear();
    recognizedText.value = '';
    aiState.value = null;
  }

  void loadChat(String chatId) {
    currentChatId.value = chatId;
    textController.clear();
    recognizedText.value = '';
    aiState.value = null;
    if (Get.isOverlaysOpen) Get.back();
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('chats').doc(chatId)
          .delete();
      if (currentChatId.value == chatId) startNewChat();
    } catch (e) {
      print("Erreur suppression: $e");
    }
  }

  Stream<List<String>> get sessionsStream {
    return FirebaseFirestore.instance
        .collection('users').doc(uid)
        .collection('chats')
        .snapshots()
        .map((s) => s.docs.map((d) => d.id).toList()..sort((a, b) => b.compareTo(a)));
  }

  // =========================================================
  // SPEECH TO TEXT — MULTILINGUE
  // =========================================================

  Future<void> _initSpeech() async {
    try {
      var status = await Permission.microphone.status;
      if (!status.isGranted) status = await Permission.microphone.request();

      if (status.isGranted) {
        speechAvailable.value = await _speechToText.initialize(
          onError: (error) {
            print("STT Error: $error");
            isListening.value = false;
          },
          onStatus: (status) {
            print("STT Status: $status");
            if (status == 'notListening' && isListening.value) {
              Future.delayed(const Duration(milliseconds: 800), () {
                if (isListening.value) stopListening();
              });
            }
          },
          debugLogging: true,
        );
        print("STT disponible: ${speechAvailable.value}");
      }
    } catch (e) {
      print("Erreur STT init: $e");
    }
  }

  void changeLocale(String localeId) {
    selectedLocale.value = localeId;
    if (isListening.value) {
      stopListening().then((_) => startListening());
    }
  }

  void toggleListening() {
  if (isListening.value) {
    stopListening();
  } else {
    startListening();
  }
}

  Future<void> startListening() async {
    if (!speechAvailable.value) return;
    isListening.value = true;
    recognizedText.value = '';

    // Récupère toutes les locales supportées par l'appareil
    final locales = await _speechToText.locales();
    print("Locales dispo: ${locales.map((l) => l.localeId).toList()}");

    // Cherche la meilleure locale disponible pour la langue choisie
    final String targetLang = selectedLocale.value.split('_').first; // 'ar', 'fr', 'en'
    String bestLocale = selectedLocale.value;

    final match = locales.firstWhereOrNull(
      (l) => l.localeId.toLowerCase().startsWith(targetLang),
    );
    if (match != null) {
      bestLocale = match.localeId;
      print("Locale finale utilisée: $bestLocale");
    }

    await _speechToText.listen(
      onResult: (result) {
        recognizedText.value = result.recognizedWords;
        textController.text = result.recognizedWords;
      },
      localeId: bestLocale,
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 5),
      listenMode: ListenMode.confirmation,
    );
  }

  Future<void> stopListening() async {
    if (!isListening.value) return;
    await _speechToText.stop();
    isListening.value = false;
    if (textController.text.trim().isNotEmpty) sendMessage();
  }

  // =========================================================
  // ENVOI + SUIVI ÉTAT IA (thinking → replying → done)
  // =========================================================

  void sendMessage() async {
    final String msg = textController.text.trim();
    if (msg.isEmpty) return;

    textController.clear();
    recognizedText.value = '';

    // 1. Affiche "Thinking..." immédiatement
    aiState.value = 'thinking';

    try {
      final chatRef = FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('chats').doc(currentChatId.value);

      await chatRef.set(
        {'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );

      await chatRef.collection('messages').add({
        'text': msg,
        'sender': 'user',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. Après 2s → passe à "Replying..."
      await Future.delayed(const Duration(seconds: 2));
      if (aiState.value == 'thinking') aiState.value = 'replying';

      // 3. Écoute la prochaine réponse IA et reset l'état
      _listenForAiReply(chatRef);

    } catch (e) {
      print("Erreur Firestore: $e");
      aiState.value = null;
    }
  }

  void _listenForAiReply(DocumentReference chatRef) {
    final sentAt = DateTime.now();
    final sub = chatRef.collection('messages')
        .where('sender', isEqualTo: 'ai')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final ts = snapshot.docs.first.data()['timestamp'];
        if (ts != null) {
          final msgTime = (ts as Timestamp).toDate();
          if (msgTime.isAfter(sentAt.subtract(const Duration(seconds: 5)))) {
            aiState.value = null;
          }
        }
      }
    });

    // Timeout sécurité 30s
    Future.delayed(const Duration(seconds: 30), () {
      if (aiState.value != null) {
        aiState.value = null;
        sub.cancel();
      }
    });
  }

  Stream<List<ChatMessage>> get messagesStream {
    return FirebaseFirestore.instance
        .collection('users').doc(uid)
        .collection('chats').doc(currentChatId.value)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ChatMessage.fromFirestore(d.data())).toList());
  }

  @override
  void onClose() {
    textController.dispose();
    _speechToText.cancel();
    super.onClose();
  }
}