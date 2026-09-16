import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AllFeaturesScreen extends StatefulWidget {
  const AllFeaturesScreen({super.key});

  @override
  State<AllFeaturesScreen> createState() => _AllFeaturesScreenState();
}

class _AllFeaturesScreenState extends State<AllFeaturesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _featureCategories = [
    {
      'category': 'Simulasi Ujian & CBT UTBK',
      'description': 'Latihan soal dan simulasi sistem IRT nasional',
      'items': [
        {
          'title': 'Tryout CBT IRT',
          'sub': 'Simulasi UTBK & Kedinasan berkala',
          'icon': Icons.assignment_rounded,
          'color': const Color(0xFFFF6B6B),
          'badge': 'HOT',
          'route': '/package_list',
        },
        {
          'title': 'Bank Soal HOTS',
          'sub': 'Ribuan soal kurikulum terbaru + pembahasan',
          'icon': Icons.menu_book_rounded,
          'color': const Color(0xFFFF9F43),
          'badge': 'NEW',
          'route': '/package_list',
        },
        {
          'title': 'Rapor & Analisis IRT',
          'sub': 'Statistik akurasi per subtes & peluang lolos',
          'icon': Icons.analytics_rounded,
          'color': const Color(0xFFEE5253),
          'badge': 'SCORE',
          'route': '/result',
        },
        {
          'title': 'Pembahasan & Kunci Soal',
          'sub': 'Review jawaban tryout dan trik cepat',
          'icon': Icons.fact_check_rounded,
          'color': const Color(0xFF10B981),
          'badge': '',
          'route': '/review',
        },
        {
          'title': 'Pretest Kilat 5 Menit',
          'sub': 'Uji kemampuan awal sebelum mulai belajar',
          'icon': Icons.flash_on_rounded,
          'color': const Color(0xFFF59E0B),
          'badge': 'KILAT',
          'route': '/pretest',
        },
      ],
    },
    {
      'category': 'Kelas, Materi & Mentoring',
      'description': 'Materi komprehensif dari Master Tutor',
      'items': [
        {
          'title': 'Modul & Materi Saya',
          'sub': 'Rangkuman bab, rumus sakti, & PDF materi',
          'icon': Icons.auto_stories_rounded,
          'color': const Color(0xFF0066FF),
          'badge': '',
          'route': '/home',
        },
        {
          'title': 'Live Class Interaktif',
          'sub': 'Sesi tanya jawab tatap maya dengan tutor',
          'icon': Icons.video_camera_front_rounded,
          'color': const Color(0xFF2196F3),
          'badge': 'LIVE',
          'route': '/video_list',
        },
        {
          'title': 'Rekaman Video Materi',
          'sub': 'Akses video pembahasan materi kapan saja',
          'icon': Icons.play_circle_fill_rounded,
          'color': const Color(0xFF6C5CE7),
          'badge': 'HD',
          'route': '/video_list',
        },
        {
          'title': 'AI Tutor Pintar 24/7',
          'sub': 'Tanya jawab soal sulit matematika, fisika, dll',
          'icon': Icons.smart_toy_rounded,
          'color': const Color(0xFF9C27B0),
          'badge': '24/7',
          'route': '/ai_chat',
        },
        {
          'title': 'Direktori Master Tutor',
          'sub': 'Profil pengajar lulusan PTN terbaik',
          'icon': Icons.school_rounded,
          'color': const Color(0xFF00B894),
          'badge': '',
          'route': '/home',
        },
      ],
    },
    {
      'category': 'Target PTN & Gamifikasi Belajar',
      'description': 'Pantau perkembangan dan raih kampus impian',
      'items': [
        {
          'title': 'Target PTN & Jurusan',
          'sub': 'Simulasi rasio keketatan dan passing grade',
          'icon': Icons.flag_rounded,
          'color': const Color(0xFF3B82F6),
          'badge': 'TARGET',
          'action': 'target_ptn',
        },
        {
          'title': 'Grafik Progres Belajar',
          'sub': 'Riwayat jam belajar dan skor mingguan',
          'icon': Icons.trending_up_rounded,
          'color': const Color(0xFF10B981),
          'badge': '',
          'route': '/home',
        },
        {
          'title': 'Leaderboard Nasional',
          'sub': 'Peringkat skor TO se-Indonesia',
          'icon': Icons.emoji_events_rounded,
          'color': const Color(0xFFF59E0B),
          'badge': 'TOP',
          'action': 'leaderboard',
        },
        {
          'title': 'Streak Belajar & Koin XP',
          'sub': 'Kumpulkan poin belajar untuk hadiah menarik',
          'icon': Icons.local_fire_department_rounded,
          'color': const Color(0xFFEF4444),
          'badge': 'STREAK',
          'action': 'streak',
        },
      ],
    },
    {
      'category': 'Membership, Paket & Pembayaran',
      'description': 'Akses langganan dan aktivasi voucher',
      'items': [
        {
          'title': 'Klaim Enroll Key',
          'sub': 'Aktivasi kode voucher sekolah / mitra bimbel',
          'icon': Icons.vpn_key_rounded,
          'color': const Color(0xFF00B894),
          'badge': 'KLAIM',
          'route': '/enroll_key',
        },
        {
          'title': 'Katalog Paket Belajar',
          'sub': 'Pilihan langganan bulanan & tahunan',
          'icon': Icons.card_membership_rounded,
          'color': const Color(0xFF0ABDE3),
          'badge': 'PROMO',
          'route': '/package_list',
        },
        {
          'title': 'Keranjang & Checkout',
          'sub': 'Selesaikan pembayaran paket pilihanmu',
          'icon': Icons.shopping_cart_rounded,
          'color': const Color(0xFF6366F1),
          'badge': '',
          'route': '/checkout',
        },
      ],
    },
    {
      'category': 'Pusat Bantuan & Pengaturan Akun',
      'description': 'Kelola akun, keamanan, dan bantuan teknis',
      'items': [
        {
          'title': 'Notifikasi & Info Ujian',
          'sub': 'Pengumuman jadwal TO & pembaharuan sistem',
          'icon': Icons.notifications_rounded,
          'color': const Color(0xFFF97316),
          'badge': '',
          'route': '/notification',
        },
        {
          'title': 'Profil Siswa',
          'sub': 'Ubah data diri, sekolah, dan kelas',
          'icon': Icons.person_rounded,
          'color': const Color(0xFF06B6D4),
          'badge': '',
          'route': '/profile',
        },
        {
          'title': 'Pengaturan Akun',
          'sub': 'Ganti kata sandi & preferensi notifikasi',
          'icon': Icons.settings_rounded,
          'color': const Color(0xFF64748B),
          'badge': '',
          'route': '/settings',
        },
        {
          'title': 'Hubungi Admin / Tutor CS',
          'sub': 'Bantuan via WhatsApp & Customer Care',
          'icon': Icons.support_agent_rounded,
          'color': const Color(0xFF22C55E),
          'badge': 'ONLINE',
          'action': 'contact_cs',
        },
      ],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleItemTap(Map<String, dynamic> item) {
    if (item['route'] != null) {
      Navigator.pushNamed(context, item['route']);
    } else if (item['action'] != null) {
      _handleSpecialAction(item['action'], item['title']);
    }
  }

  void _handleSpecialAction(String action, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(
          action == 'target_ptn'
              ? 'Target PTN aktif kamu saat ini: ITB / UI SNBT 2025. Terus selesaikan paket tryout untuk meningkatkan peluang lolos!'
              : action == 'leaderboard'
                  ? 'Leaderboard Tryout Nasional diperbarui setiap hari Minggu pukul 23.59 WIB berdasarkan skor IRT resmi.'
                  : action == 'streak'
                      ? 'Streak Belajar kamu: 5 Hari Beruntun 🔥! Raih 100 XP tambahan dengan belajar minimal 20 menit setiap hari.'
                      : 'Layanan WhatsApp Customer Care KPM aktif setiap hari pukul 08.00 - 21.00 WIB di nomor 0812-3456-7890.',
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toLowerCase();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Semua Fitur & Layanan 🚀',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Search Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  icon: const Icon(Icons.search_rounded, color: Colors.grey, size: 22),
                  hintText: 'Cari fitur, materi, tryout, atau tutor...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  border: InputBorder.none,
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // 2. Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.ruangguruGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0072FF).withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.hub_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pusat Ekosistem KPM Academy',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Semua fitur tryout, materi, live class, & AI tutor lengkap di satu tempat.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Render Categorized Features
            ..._featureCategories.map((cat) {
              final List<Map<String, dynamic>> items = (cat['items'] as List<Map<String, dynamic>>)
                  .where((item) {
                    if (query.isEmpty) return true;
                    final title = (item['title'] as String).toLowerCase();
                    final sub = (item['sub'] as String).toLowerCase();
                    return title.contains(query) || sub.contains(query);
                  })
                  .toList();

              if (items.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cat['category'],
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat['description'],
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 0.8,
                        indent: 68,
                        color: Colors.grey.shade100,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return InkWell(
                          onTap: () => _handleItemTap(item),
                          borderRadius: BorderRadius.vertical(
                            top: index == 0 ? const Radius.circular(20) : Radius.zero,
                            bottom: index == items.length - 1 ? const Radius.circular(20) : Radius.zero,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  height: 44,
                                  width: 44,
                                  decoration: BoxDecoration(
                                    color: (item['color'] as Color).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              item['title'] as String,
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if ((item['badge'] as String).isNotEmpty) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: item['badge'] == 'HOT' || item['badge'] == 'LIVE'
                                                    ? Colors.red
                                                    : item['badge'] == 'NEW'
                                                        ? Colors.orange
                                                        : AppTheme.primaryBlue,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                item['badge'] as String,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 8.5,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item['sub'] as String,
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
