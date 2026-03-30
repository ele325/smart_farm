import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat_controller.dart';
import '../../widgets/chat_bubble.dart';
import 'package:avatar_glow/avatar_glow.dart';

class ChatPage extends GetView<ChatController> {
  @override
  final ChatController controller = Get.put(ChatController());

  ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("chat_bot_title".tr),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // ── Sélecteur de langue micro ──
          Obx(
            () => PopupMenuButton<String>(
              tooltip: "Langue du micro",
              icon: Text(
                ChatController.localeLabels[controller.selectedLocale.value]!
                    .split(' ')
                    .first,
                style: const TextStyle(fontSize: 22),
              ),
              onSelected: controller.changeLocale,
              itemBuilder: (context) => ChatController.localeLabels.entries.map(
                (e) {
                  final isSelected = controller.selectedLocale.value == e.key;
                  return PopupMenuItem(
                    value: e.key,
                    child: Row(
                      children: [
                        Text(
                          e.value.split(' ').first,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          e.value.split(' ').last,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.green[700]
                                : Colors.black87,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.check, color: Colors.green[700], size: 18),
                        ],
                      ],
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_comment_rounded),
            tooltip: "new_chat_tooltip".tr,
            onPressed: () => controller.startNewChat(),
          ),
        ],
      ),

      // ── Drawer historique ──
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[700]),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.history, color: Colors.white, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      "history_title".tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<String>>(
                stream: controller.sessionsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return  Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("no_history".tr, ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final chatId = snapshot.data![index];
                      // On récupère la date formatée
                      final formattedDate = DateTime.fromMillisecondsSinceEpoch(int.parse(chatId)).toString().substring(0, 16);

// On utilise la clé de traduction concaténée à la date
                      final dateStr = "${'session_prefix'.tr} $formattedDate";
                      return Obx(
                        () => ListTile(
                          leading: Icon(
                            Icons.chat_bubble_outline,
                            color: controller.currentChatId.value == chatId
                                ? Colors.green
                                : Colors.grey,
                          ),
                          title: Text(
                            dateStr,
                            style: const TextStyle(fontSize: 14),
                          ),
                          selected: controller.currentChatId.value == chatId,
                          selectedTileColor: Colors.green[50],
                          onTap: () => controller.loadChat(chatId),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            onPressed: () => _showDeleteDialog(chatId),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // ── Liste des messages ──
          Expanded(
            child: Obx(
              () => StreamBuilder(
                key: ValueKey(controller.currentChatId.value),
                stream: controller.messagesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final m = snapshot.data![index];
                      return ChatBubble(
                        message: m.text,
                        isUser: m.sender == 'user',
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // ── Bannière THINKING / REPLYING ──
          Obx(() {
            final state = controller.aiState.value;
            if (state == null) return const SizedBox.shrink();
            return _buildAiBanner(state);
          }),

          // ── Indicateur micro actif ──
          Obx(
            () => controller.isListening.value
                ? _buildListeningIndicator()
                : const SizedBox.shrink(),
          ),

          // ── Zone de saisie ──
          _buildInputArea(),
        ],
      ),
    );
  }

  // ── Bannière animée thinking / replying ──
  Widget _buildAiBanner(String state) {
    final isThinking = state == 'thinking';
    final color = isThinking ? Colors.orange : Colors.blue;
    final label = controller.getStateLabel(state);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          // Dots animés
          _AnimatedDots(color: color),
        ],
      ),
    );
  }

  // ── Indicateur micro ──
  Widget _buildListeningIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.mic, color: Colors.red),
          const SizedBox(width: 8),
          Obx(
            () => Text(
              ChatController.localeLabels[controller.selectedLocale.value]!
                      .split(' ')
                      .first +
                  ' ' +
                  controller.getStateLabel('listening'),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Obx(
              () => Text(
                controller.recognizedText.value.isEmpty
                    ? ''
                    : controller.recognizedText.value,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
                textDirection: controller.selectedLocale.value == 'ar_SA'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Zone de saisie ──
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => TextField(
                controller: controller.textController,
                textDirection: controller.selectedLocale.value == 'ar_SA'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: _getHintText(controller.selectedLocale.value),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // ── Zone de saisie mise à jour avec AvatarGlow ──
          Obx(
            () => AvatarGlow(
              animate: controller
                  .isListening
                  .value, // S'anime seulement quand on écoute
              glowColor: Colors.red,
              endRadius: 28.0, // Rayon de l'effet
              duration: const Duration(milliseconds: 2000),
              repeat: true,
              showTwoGlows: true,
              repeatPauseDuration: const Duration(milliseconds: 100),
              child: FloatingActionButton(
                mini: true,
                heroTag: "mic_btn",
                backgroundColor: controller.isListening.value
                    ? Colors.red
                    : Colors.green[50],
                onPressed: controller.toggleListening,
                child: Icon(
                  controller.isListening.value ? Icons.stop : Icons.mic,
                  color: controller.isListening.value
                      ? Colors.white
                      : Colors.green[700],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: controller.sendMessage,
            child: CircleAvatar(
              backgroundColor: Colors.green[700],
              radius: 22,
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  String _getHintText(String locale) {
    switch (locale) {
      case 'ar_SA':
        return 'اكتب هنا...';
      case 'en_US':
        return 'Type here...';
      default:
        return 'Écrivez ici...';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco_outlined, size: 80, color: Colors.green[100]),
          SizedBox(height: 10),
           Text(
            "new_chat_tooltip".tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const Text(
            "Posez une question sur vos cultures.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String chatId) {
    Get.dialog(
      AlertDialog(
        title:  Text("delete_confirm_title".tr),
        content:  Text("delete_confirm_msg".tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Non")),
          TextButton(
            onPressed: () {
              controller.deleteChat(chatId);
              Get.back();
            },
            child: Text("yes_delete".tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ── Widget points animés ──
class _AnimatedDots extends StatefulWidget {
  final Color color;
  const _AnimatedDots({required this.color});

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<int> _dotCount;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _dotCount = IntTween(begin: 1, end: 3).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotCount,
      builder: (_, __) => Text(
        '.' * _dotCount.value,
        style: TextStyle(
          color: widget.color,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
