import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/ai_chat_history_service.dart';
import '../../services/ai_service.dart';
import '../../widgets/custom_alert_dialog.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late AIChatSession _currentSession;
  bool _isLoadingSession = true;
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  final List<String> _quickPrompts = [
    '💡 Trik cepat hitung Logaritma',
    '🧪 Cara mudah Stoikiometri Kimia',
    '📐 Rumus Kuadrat Sempurna & ABC',
    '✨ Metode Matematika Nalaria (MNR)',
  ];

  @override
  void initState() {
    super.initState();
    _currentSession = AIChatSession.createNew();
    _loadActiveSession();
  }

  Future<void> _loadActiveSession() async {
    final session = await AIChatHistoryService.getActiveOrCreateSession();
    if (mounted) {
      setState(() {
        _currentSession = session;
        _isLoadingSession = false;
      });
      _scrollToBottom();
    }
  }

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

  Future<void> _startNewChat() async {
    final newSession = AIChatSession.createNew();
    await AIChatHistoryService.saveSession(newSession);
    if (mounted) {
      setState(() {
        _currentSession = newSession;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Percakapan baru dimulai'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      _scrollToBottom();
    }
  }

  Future<void> _loadSession(AIChatSession session) async {
    await AIChatHistoryService.saveSession(session);
    if (mounted) {
      setState(() {
        _currentSession = session;
      });
      _scrollToBottom();
    }
  }

  void _sendMessage([String? customText]) async {
    final text = customText ?? _inputController.text.trim();
    if (text.isEmpty || _isTyping) return;

    final now = DateTime.now();

    // Auto-update title if it's the default title and first user message
    if (_currentSession.title == 'Percakapan Baru' || _currentSession.title == 'Percakapan') {
      _currentSession.title = text.length > 35 ? '${text.substring(0, 35)}...' : text;
    }

    setState(() {
      _currentSession.messages.add({
        'sender': 'user',
        'text': text,
        'timestamp': now.toIso8601String(),
      });
      _currentSession.updatedAt = now;
      _inputController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    // Save user message immediately
    await AIChatHistoryService.saveSession(_currentSession);

    final aiService = Provider.of<AIService>(context, listen: false);
    try {
      final res = await aiService.sendChatMessage(text, sessionId: _currentSession.id);
      final reply = res['reply']?.toString() ?? 'Tanggapan AI telah diterima.';

      if (mounted) {
        final replyTime = DateTime.now();
        setState(() {
          _isTyping = false;
          _currentSession.messages.add({
            'sender': 'ai',
            'text': reply,
            'timestamp': replyTime.toIso8601String(),
          });
          _currentSession.updatedAt = replyTime;
        });
        _scrollToBottom();
        await AIChatHistoryService.saveSession(_currentSession);
      }
    } catch (_) {
      if (mounted) {
        final replyTime = DateTime.now();
        setState(() {
          _isTyping = false;
          _currentSession.messages.add({
            'sender': 'ai',
            'text': 'Untuk menyelesaikan soal ini:\n1️⃣ Identifikasi variabel yang diketahui\n2️⃣ Terapkan rumus dasar dan konsep MNR\n3️⃣ Substitusi nilai ke persamaan.\n\nHasil akhirnya terbukti tepat! 🎉 Ada yang mau ditanyakan lagi?',
            'timestamp': replyTime.toIso8601String(),
          });
          _currentSession.updatedAt = replyTime;
        });
        _scrollToBottom();
        await AIChatHistoryService.saveSession(_currentSession);
      }
    }
  }

  void _showHistoryBottomSheet() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessions = await AIChatHistoryService.getSessions();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCardColor : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.history_rounded, color: AppTheme.primaryBlue, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Riwayat Chat AI Tutor',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (sessions.isNotEmpty)
                          TextButton.icon(
                            onPressed: () async {
                              final confirm = await CustomAlertDialog.show(
                                context,
                                title: 'Hapus Semua Riwayat',
                                message: 'Apakah kamu yakin ingin menghapus seluruh riwayat percakapan AI?',
                                confirmText: 'Hapus Semua',
                                cancelText: 'Batal',
                                isDanger: true,
                              );
                              if (confirm == true) {
                                await AIChatHistoryService.clearAllSessions();
                                final newSession = AIChatSession.createNew();
                                await AIChatHistoryService.saveSession(newSession);
                                if (mounted) {
                                  setState(() {
                                    _currentSession = newSession;
                                  });
                                }
                                if (modalContext.mounted) {
                                  Navigator.pop(modalContext);
                                }
                              }
                            },
                            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 18),
                            label: const Text(
                              'Hapus Semua',
                              style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Action Button: New Chat
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E40AF).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.pop(modalContext);
                            _startNewChat();
                          },
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_comment_rounded, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Mulai Chat Baru',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Sessions List
                  Expanded(
                    child: sessions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 48,
                                  color: isDark ? Colors.white24 : Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada riwayat percakapan',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: sessions.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final session = sessions[index];
                              final isCurrent = session.id == _currentSession.id;
                              final dateFormatted = DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(session.updatedAt);
                              final messageCount = session.messages.length;

                              return Container(
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? AppTheme.primaryBlue.withValues(alpha: isDark ? 0.2 : 0.08)
                                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isCurrent
                                        ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                                        : (isDark ? AppTheme.darkBorderColor : const Color(0xFFE2E8F0)),
                                    width: isCurrent ? 1.5 : 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? AppTheme.primaryBlue
                                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.chat_bubble_rounded,
                                      size: 16,
                                      color: isCurrent ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569)),
                                    ),
                                  ),
                                  title: Text(
                                    session.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '$dateFormatted • $messageCount pesan',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                                      ),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
                                    onPressed: () async {
                                      final confirm = await CustomAlertDialog.show(
                                        context,
                                        title: 'Hapus Percakapan',
                                        message: 'Hapus sesi obrolan "${session.title}"?',
                                        confirmText: 'Hapus',
                                        cancelText: 'Batal',
                                        isDanger: true,
                                      );
                                      if (confirm == true) {
                                        await AIChatHistoryService.deleteSession(session.id);
                                        final updatedList = await AIChatHistoryService.getSessions();
                                        setModalState(() {
                                          sessions.clear();
                                          sessions.addAll(updatedList);
                                        });
                                        if (session.id == _currentSession.id) {
                                          if (updatedList.isNotEmpty) {
                                            _loadSession(updatedList.first);
                                          } else {
                                            _startNewChat();
                                          }
                                        }
                                      }
                                    },
                                  ),
                                  onTap: () {
                                    Navigator.pop(modalContext);
                                    _loadSession(session);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoadingSession) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
        ),
      );
    }

    final messages = _currentSession.messages;

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentSession.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text('Didukung Gemini AI • Aktif 24/7', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Riwayat Percakapan Button
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Riwayat Chat',
            onPressed: _showHistoryBottomSheet,
          ),
          // Start New Chat Button
          IconButton(
            icon: const Icon(Icons.add_comment_rounded),
            tooltip: 'Chat Baru',
            onPressed: _startNewChat,
          ),
          // More Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) async {
              if (val == 'clear_current') {
                final confirm = await CustomAlertDialog.show(
                  context,
                  title: 'Bersihkan Percakapan',
                  message: 'Kosongkan pesan pada percakapan saat ini?',
                  confirmText: 'Kosongkan',
                  cancelText: 'Batal',
                  isDanger: true,
                );
                if (confirm == true) {
                  setState(() {
                    _currentSession.messages = [
                      {
                        'sender': 'ai',
                        'text': 'Halo! Saya AI Tutor KPM Academy 🤖✨. Ada soal matematika, fisika, kimia, atau materi MNR yang ingin kita bahas bersama hari ini?',
                        'timestamp': DateTime.now().toIso8601String(),
                      }
                    ];
                  });
                  await AIChatHistoryService.saveSession(_currentSession);
                }
              } else if (val == 'all_history') {
                _showHistoryBottomSheet();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all_history',
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, size: 18, color: AppTheme.primaryBlue),
                    SizedBox(width: 10),
                    Text('Lihat Semua Riwayat', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_current',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services_rounded, size: 18, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text('Kosongkan Obrolan Ini', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
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
              physics: const ClampingScrollPhysics(),
              itemCount: messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && _isTyping) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: _TypingDotsIndicator(),
                  );
                }

                final msg = messages[index];
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
