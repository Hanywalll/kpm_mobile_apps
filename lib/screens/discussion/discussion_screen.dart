import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/auth_guard_bottom_sheet.dart';

class DiscussionTopic {
  final String id;
  final String authorName;
  final String authorSchool;
  final String authorAvatar;
  final String category;
  final String title;
  final String question;
  final int likes;
  final int repliesCount;
  final String timeAgo;
  final bool isAnsweredByTutor;
  final String? tutorReply;

  DiscussionTopic({
    required this.id,
    required this.authorName,
    required this.authorSchool,
    required this.authorAvatar,
    required this.category,
    required this.title,
    required this.question,
    required this.likes,
    required this.repliesCount,
    required this.timeAgo,
    this.isAnsweredByTutor = false,
    this.tutorReply,
  });
}

class DiscussionScreen extends StatefulWidget {
  const DiscussionScreen({super.key});

  @override
  State<DiscussionScreen> createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends State<DiscussionScreen> {
  String _selectedCategory = 'Semua';

  final List<DiscussionTopic> _topics = [
    DiscussionTopic(
      id: 'disc_1',
      authorName: 'Ahmad Fauzan',
      authorSchool: 'SMAN 1 Jakarta',
      authorAvatar: 'https://api.dicebear.com/7.x/adventurer/png?seed=Ahmad',
      category: 'Matematika Nalaria',
      title: 'Trik cepat menyelesaikan soal perbandingan berbalik nilai?',
      question: 'Halo teman-teman & Master Tutor, ada yang punya trik nalar cepat untuk soal cerita perbandingan berbalik nilai pekerja & waktu tanpa rumus panjang?',
      likes: 24,
      repliesCount: 8,
      timeAgo: '10 menit lalu',
      isAnsweredByTutor: true,
      tutorReply: 'Gunakan metode Total Beban Kerja (Orang x Hari). Konsep MNR mengajarkan untuk melihat total energi penyelesaian!',
    ),
    DiscussionTopic(
      id: 'disc_2',
      authorName: 'Siti Nurhaliza',
      authorSchool: 'SMAN 3 Surabaya',
      authorAvatar: 'https://api.dicebear.com/7.x/adventurer/png?seed=Siti',
      category: 'SNBT & UTBK',
      title: 'Strategi Manajemen Waktu Subtes Penalaran Matematika SNBT 2026',
      question: 'Bagi teman-teman yang sudah ikut tryout CBT kemarin, bagaimana cara kalian membagi 20 soal dalam 30 menit agar tidak kehabisan waktu?',
      likes: 38,
      repliesCount: 15,
      timeAgo: '1 jam lalu',
      isAnsweredByTutor: false,
    ),
    DiscussionTopic(
      id: 'disc_3',
      authorName: 'Budi Santoso',
      authorSchool: 'SMAN 8 Bandung',
      authorAvatar: 'https://api.dicebear.com/7.x/adventurer/png?seed=Budi',
      category: 'Sains & MIPA',
      title: 'Pembahasan Hukum Termodinamika & Efisiensi Mesin Carnot OSN',
      question: 'Apakah pada siklus Carnot selalu berlaku Q1/T1 = Q2/T2? Kapan kondisi reversibel tidak berlaku?',
      likes: 19,
      repliesCount: 6,
      timeAgo: '3 jam lalu',
      isAnsweredByTutor: true,
      tutorReply: 'Benar, berlaku untuk siklus reversibel ideal. Jika ada gesekan atau perpindahan kalor irreversibel, entropi total akan meningkat.',
    ),
    DiscussionTopic(
      id: 'disc_4',
      authorName: 'Dewi Lestari',
      authorSchool: 'SMAN 1 Yogyakarta',
      authorAvatar: 'https://api.dicebear.com/7.x/adventurer/png?seed=Dewi',
      category: 'Matematika Nalaria',
      title: 'Pola Bilangan Geometri Bertingkat Olimpiade MNR',
      question: 'Ada tips untuk mengenali suku ke-n pola barisan selisih bertingkat 3?',
      likes: 15,
      repliesCount: 4,
      timeAgo: '5 jam lalu',
      isAnsweredByTutor: false,
    ),
  ];

  final List<String> _categories = [
    'Semua',
    'Matematika Nalaria',
    'Sains & MIPA',
    'SNBT & UTBK',
    'Tips Belajar',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredTopics = _selectedCategory == 'Semua'
        ? _topics
        : _topics.where((t) => t.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: AppTheme.backButton(context),
        title: const Text('Forum Diskusi & Tanya Soal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.forum_outlined, color: Color(0xFF1D4ED8)),
            tooltip: 'Tanya Master Tutor',
            onPressed: () => Navigator.pushNamed(context, '/tutor'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Horizontal Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: isDark ? AppTheme.darkCardColor : Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: const Color(0xFF1D4ED8),
                      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppTheme.darkTextSecondary : const Color(0xFF475569)),
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Thread List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: filteredTopics.length,
              itemBuilder: (context, index) {
                final topic = filteredTopics[index];
                return _buildTopicCard(topic, isDark);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_rounded, size: 18),
        label: Text(
          'Tanya Soal',
          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w800),
        ),
        onPressed: () {
          AuthGuard.check(
            context,
            featureName: 'Membuat Pertanyaan Diskusi',
            onAuthenticated: () => _showCreateQuestionModal(isDark),
          );
        },
      ),
    );
  }

  Widget _buildTopicCard(DiscussionTopic topic, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.darkBorderColor : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Row & Category
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFEFF6FF),
                backgroundImage: NetworkImage(topic.authorAvatar),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.authorName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${topic.authorSchool} • ${topic.timeAgo}',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? AppTheme.darkTextMuted : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  topic.category,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            topic.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF0F172A),
              height: 1.3,
            ),
          ),

          const SizedBox(height: 6),

          // Question Body
          Text(
            topic.question,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF334155),
              height: 1.4,
            ),
          ),

          // Tutor Verified Answer Highlight
          if (topic.isAnsweredByTutor && topic.tutorReply != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified_rounded, size: 14, color: Color(0xFF16A34A)),
                      SizedBox(width: 4),
                      Text(
                        'Jawaban Master Tutor KPM',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topic.tutorReply!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF14532D),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          Divider(height: 1, color: isDark ? AppTheme.darkBorderColor : const Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Actions Row (Likes, Comments, Share)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _actionChip(
                    icon: Icons.thumb_up_alt_outlined,
                    label: '${topic.likes} Suka',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Menyukai pertanyaan ini! ❤️'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _actionChip(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: '${topic.repliesCount} Jawaban',
                    onTap: () => _showRepliesModal(topic, isDark),
                    isDark: isDark,
                  ),
                ],
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: const Size(0, 30),
                ),
                icon: const Icon(Icons.reply_rounded, size: 16, color: Color(0xFF1D4ED8)),
                label: Text(
                  'Balas',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1D4ED8),
                  ),
                ),
                onPressed: () => _showRepliesModal(topic, isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 15, color: isDark ? AppTheme.darkTextMuted : const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateQuestionModal(bool isDark) {
    final titleController = TextEditingController();
    final questionController = TextEditingController();
    String selectedCat = 'Matematika Nalaria';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Tanya Soal & Diskusi Belajar',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ajukan pertanyaanmu agar dijawab oleh teman se-Indonesia dan Master Tutor KPM.',
                    style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextMuted : const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 14),

                  // Category Selector Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: selectedCat,
                    decoration: InputDecoration(
                      labelText: 'Kategori Materi',
                      labelStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    items: ['Matematika Nalaria', 'Sains & MIPA', 'SNBT & UTBK', 'Tips Belajar']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedCat = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Title Input
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Judul pertanyaan (misal: Trik cepat soal pecahan...)',
                      hintStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Detail Question
                  TextField(
                    controller: questionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Tuliskan detail soal atau pertanyaan lengkapmu di sini...',
                      hintStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4ED8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        if (titleController.text.trim().isEmpty || questionController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Harap isi judul dan detail pertanyaan')),
                          );
                          return;
                        }

                        setState(() {
                          _topics.insert(
                            0,
                            DiscussionTopic(
                              id: 'disc_${DateTime.now().millisecondsSinceEpoch}',
                              authorName: 'Siswa KPM (Saya)',
                              authorSchool: 'KPM Academy Center',
                              authorAvatar: 'https://api.dicebear.com/7.x/adventurer/png?seed=SiswaKPM',
                              category: selectedCat,
                              title: titleController.text.trim(),
                              question: questionController.text.trim(),
                              likes: 1,
                              repliesCount: 0,
                              timeAgo: 'Baru saja',
                            ),
                          );
                        });

                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pertanyaanmu berhasil diposting ke Forum Diskusi KPM! 🚀'),
                            backgroundColor: Color(0xFF1D4ED8),
                          ),
                        );
                      },
                      child: Text(
                        'Posting Pertanyaan',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRepliesModal(DiscussionTopic topic, bool isDark) {
    final replyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Balas Pertanyaan: ${topic.title}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF0F172A),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: replyController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tuliskan jawaban atau tips bantuanmu...',
                  hintStyle: const TextStyle(fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (replyController.text.trim().isNotEmpty) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Jawaban berhasil dikirimkan! Terima kasih telah membantu sesama siswa. 🎉'),
                          backgroundColor: Color(0xFF059669),
                        ),
                      );
                    }
                  },
                  child: const Text('Kirim Balasan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
