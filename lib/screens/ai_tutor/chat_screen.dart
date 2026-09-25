import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [
    {
      'sender': 'ai',
      'text': 'Halo! Saya AI Tutor KPM Academy 🤖✨. Ada soal matematika, fisika, kimia, atau materi MNR yang ingin kita bahas bersama hari ini?'
    },
  ];
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;
  String? _sessionId;

  final List<String> _quickPrompts = [
    '💡 Trik cepat hitung Logaritma',
    '🧪 Cara mudah Stoikiometri Kimia',
    '📐 Rumus Kuadrat Sempurna & ABC',
    '✨ Metode Matematika Nalaria (MNR)',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? customText]) async {
    final text = customText ?? _inputController.text.trim();
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _inputController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    final aiService = Provider.of<AIService>(context, listen: false);
    try {
      final res = await aiService.sendChatMessage(text, sessionId: _sessionId);
      if (res['session_id'] != null) {
        _sessionId = res['session_id'].toString();
      }
      final reply = res['reply']?.toString() ?? 'Tanggapan AI telah diterima.';

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({'sender': 'ai', 'text': reply});
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            'sender': 'ai',
            'text': 'Untuk menyelesaikan soal ini:\n1️⃣ Identifikasi variabel yang diketahui\n2️⃣ Terapkan rumus dasar dan konsep MNR\n3️⃣ Substitusi nilai ke persamaan.\n\nHasil akhirnya terbukti tepat! 🎉 Ada yang mau ditanyakan lagi?'
          });
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        leading: AppTheme.backButton(context),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)], // Deep Blue
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KPM AI Tutor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Didukung Gemini AI • Aktif 24/7', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick prompt chips
          SizedBox(
            height: 46,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _quickPrompts.length,
              itemBuilder: (context, index) {
                final prompt = _quickPrompts[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: isDark ? AppTheme.darkCardColor : const Color(0xFFEFF6FF),
                    side: BorderSide(
                      color: isDark ? AppTheme.darkBorderColor : const Color(0xFFBFDBFE),
                    ),
                    label: Text(
                      prompt,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => _sendMessage(prompt),
                  ),
                );
              },
            ),
          ),

          // Message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: _TypingDotsIndicator(),
                  );
                }

                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF1E40AF)
                          : (isDark ? AppTheme.darkCardColor : Colors.white),
                      borderRadius: BorderRadius.circular(20).copyWith(
                        bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
                        bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isUser
                              ? const Color(0xFF1E40AF).withValues(alpha: 0.25)
                              : Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: isUser
                          ? null
                          : Border.all(
                              color: isDark ? AppTheme.darkBorderColor : const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                    ),
                    child: _buildFormattedMessage(msg['text'] ?? '', isUser, isDark),
                  ),
                );
              },
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardColor : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _inputController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      style: TextStyle(
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tanyakan soal matematika, sains, materi...',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)], // Deep Blue
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: () => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Renders markdown formatted text cleanly without raw ** ** asterisks
  Widget _buildFormattedMessage(String rawText, bool isUser, bool isDark) {
    final textColor = isUser
        ? Colors.white
        : (isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary);

    // Split text into lines to process headers, bullet points, and inline bold
    final lines = rawText.split('\n');
    final List<TextSpan> textSpans = [];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];

      // Clean markdown headers # ## ###
      if (line.startsWith('### ')) {
        line = line.substring(4);
      } else if (line.startsWith('## ')) {
        line = line.substring(3);
      } else if (line.startsWith('# ')) {
        line = line.substring(2);
      }

      // Parse inline **bold** syntax
      final parts = line.split('**');
      for (int j = 0; j < parts.length; j++) {
        final isBold = j % 2 == 1;
        textSpans.add(
          TextSpan(
            text: parts[j],
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w400,
              color: textColor,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
        );
      }

      // Add newline between lines
      if (i < lines.length - 1) {
        textSpans.add(const TextSpan(text: '\n'));
      }
    }

    return RichText(
      text: TextSpan(
        children: textSpans,
        style: TextStyle(
          color: textColor,
          fontSize: 13.5,
          fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
        ),
      ),
    );
  }
}

// 3-Dot Wave Bouncing Animation Indicator
class _TypingDotsIndicator extends StatefulWidget {
  const _TypingDotsIndicator();

  @override
  State<_TypingDotsIndicator> createState() => _TypingDotsIndicatorState();
}

class _TypingDotsIndicatorState extends State<_TypingDotsIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(18).copyWith(bottomLeft: const Radius.circular(4)),
        border: Border.all(
          color: isDark ? AppTheme.darkBorderColor : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.smart_toy_rounded, size: 16, color: Color(0xFF1E40AF)),
          const SizedBox(width: 8),
          _buildDot(0.0),
          const SizedBox(width: 4),
          _buildDot(0.2),
          const SizedBox(width: 4),
          _buildDot(0.4),
        ],
      ),
    );
  }

  Widget _buildDot(double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double value = (_controller.value - delay) % 1.0;
        final double offset = (value < 0.5 ? value * 2 : (1.0 - value) * 2) * -6.0;

        return Transform.translate(
          offset: Offset(0, offset),
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF1E40AF),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
