import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  ChatMessage({required this.text, required this.isUser, required this.time});
}

final _chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>(
    (ref) => ChatNotifier());

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier()
      : super([
          ChatMessage(
              text:
                  "As-salamu alaykum! I'm your Islamic assistant. Ask me about prayer, Quran, fiqh, or any Islamic topic.",
              isUser: false,
              time: DateTime.now()),
        ]);

  static const Map<String, String> _responses = {
    'prayer':
        'The five daily prayers (Salah) are Fajr, Dhuhr, Asr, Maghrib, and Isha. They are obligatory for every Muslim and are one of the five pillars of Islam.',
    'quran':
        'The Quran is the holy book of Islam, revealed to Prophet Muhammad ﷺ over 23 years. It contains 114 Surahs (chapters) and is the word of Allah.',
    'zakat':
        'Zakat is obligatory charity — 2.5% of your savings above the nisab threshold, paid annually. It is one of the five pillars of Islam.',
    'ramadan':
        'Ramadan is the 9th month of the Islamic calendar, during which Muslims fast from dawn (Fajr) to sunset (Maghrib). It commemorates the first revelation of the Quran.',
    'hajj':
        'Hajj is the annual pilgrimage to Mecca, obligatory once in a lifetime for Muslims who are physically and financially able. It is the 5th pillar of Islam.',
    'fasting':
        'Fasting (Sawm) in Ramadan means abstaining from food, drink, and other invalidating acts from Fajr to Maghrib. It increases taqwa and gratitude.',
    'dua':
        'Du\'a is supplication — speaking directly to Allah. The best times for du\'a include the last third of the night, between adhan and iqamah, and when it rains.',
    'wudu':
        'Wudu (ablution) is ritual purification required before prayer. It involves washing the hands, face, arms, wiping the head, and washing the feet.',
    'sunnah':
        'Sunnah refers to the practices, sayings, and approvals of Prophet Muhammad ﷺ. Following the Sunnah is highly recommended for every Muslim.',
    'hadith':
        'Hadith are recorded sayings and actions of Prophet Muhammad ﷺ. The most authentic collections are Bukhari and Muslim.',
    'halal':
        'Halal means "permissible" in Islam. It applies to food, actions, and lifestyle. The opposite is haram (forbidden).',
    'shahada':
        'The Shahada is the Islamic declaration of faith: "La ilaha illallah, Muhammadur rasulullah" — There is no god but Allah, and Muhammad is His messenger.',
    'istikhara':
        'Salat al-Istikhara is a 2-rakat prayer seeking Allah\'s guidance when making an important decision. It is followed by a specific du\'a.',
    'kindness':
        'The Prophet ﷺ said: "None of you truly believes until he loves for his brother what he loves for himself." Kindness and mercy are core Islamic values.',
    'patience':
        'Sabr (patience) is highly valued in Islam. Allah says: "Indeed, Allah is with the patient." (Al-Baqarah 2:153). Patience in hardship brings great reward.',
  };

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final userMsg =
        ChatMessage(text: text.trim(), isUser: true, time: DateTime.now());
    state = [...state, userMsg];
    Future.delayed(const Duration(milliseconds: 800), () {
      final response = _generateResponse(text.toLowerCase());
      final botMsg =
          ChatMessage(text: response, isUser: false, time: DateTime.now());
      state = [...state, botMsg];
    });
  }

  String _generateResponse(String query) {
    for (final entry in _responses.entries) {
      if (query.contains(entry.key)) return entry.value;
    }
    if (query.contains('hello') ||
        query.contains('salam') ||
        query.contains('hi')) {
      return 'Wa alaykum as-salam wa rahmatullahi wa barakatuh! How can I help you today?';
    }
    if (query.contains('thank')) {
      return 'Jazakallahu khayran (May Allah reward you with good). How else can I help?';
    }
    if (query.contains('pillar') || query.contains('five')) {
      return 'The Five Pillars of Islam are: 1) Shahada (declaration of faith), 2) Salah (prayer), 3) Zakat (charity), 4) Sawm (fasting in Ramadan), 5) Hajj (pilgrimage to Mecca).';
    }
    return 'JazakAllahu khayran for your question. This topic requires detailed scholarship. I recommend consulting a qualified Islamic scholar for accurate guidance. Is there anything specific about prayer, Quran, or Islamic practices I can help with?';
  }
}

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});
  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  final List<String> _suggestions = [
    'What are the 5 pillars of Islam?',
    'How do I perform Wudu?',
    'What is Zakat?',
    'Tell me about Ramadan',
    'Best times for Du\'a',
    'What is Istikhara?',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final msg = text ?? _ctrl.text;
    ref.read(_chatProvider.notifier).sendMessage(msg);
    _ctrl.clear();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(_chatProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient, shape: BoxShape.circle),
              child: const Center(
                  child: Text('☪', style: TextStyle(fontSize: 18)))),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Islamic Assistant',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            Text('Online',
                style: TextStyle(fontSize: 11, color: AppColors.success)),
          ]),
        ]),
        centerTitle: false,
      ),
      body: Column(children: [
        // Suggestions
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) => GestureDetector(
              onTap: () => _send(_suggestions[i]),
              child: Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(_suggestions[i],
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: messages.length,
            itemBuilder: (ctx, i) => _ChatBubble(message: messages[i]),
          ),
        ),

        // Input
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4))
            ],
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                decoration: InputDecoration(
                  hintText: 'Ask a question...',
                  filled: true,
                  fillColor:
                      isDark ? AppColors.surfaceDark : const Color(0xFFF5F7F6),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => _send(),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _send(),
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: const Text('☪', style: TextStyle(fontSize: 14))),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : (isDark ? AppColors.cardDark : const Color(0xFFF0F4F2)),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: Text(message.text,
                  style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isUser
                          ? Colors.white
                          : (isDark ? Colors.white : AppColors.textDark))),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
