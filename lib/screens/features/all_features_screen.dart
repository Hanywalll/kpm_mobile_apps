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
      'category': 'Simulasi Ujian & Asesmen',
      'items': [
        {
          'title': 'Simulasi Ujian Online',
          'icon': Icons.assignment_rounded,
          'color': const Color(0xFF1D4ED8),
          'badge': 'HOT',
          'route': '/package_list',
        },
        {
          'title': 'Bank Soal MNR',
          'icon': Icons.menu_book_rounded,
          'color': const Color(0xFF0284C7),
          'badge': 'NEW',
          'route': '/package_list',
        },
        {
          'title': 'Rapor Skor',
          'icon': Icons.analytics_rounded,
          'color': const Color(0xFFF59E0B),
          'badge': '',
          'route': '/result',
        },
        {
          'title': 'Pembahasan',
          'icon': Icons.fact_check_rounded,
          'color': const Color(0xFF10B981),
          'badge': '',
          'route': '/review',
        },
        {
          'title': 'Pretest Kilat',
          'icon': Icons.flash_on_rounded,
          'color': const Color(0xFFF97316),
          'badge': '5 MNT',
          'route': '/pretest',
        },
      ],
    },
    {
      'category': 'Kelas & Pembelajaran',
      'items': [
        {
          'title': 'Paket Belajar',
          'icon': Icons.school_rounded,
          'color': const Color(0xFF1D4ED8),
          'badge': '',
          'route': '/package_list',
        },
        {
          'title': 'Live Class',
          'icon': Icons.video_camera_front_rounded,
          'color': const Color(0xFFEC4899),
          'badge': 'LIVE',
          'route': '/live_class',
        },
        {
          'title': 'Video Materi',
          'icon': Icons.play_circle_fill_rounded,
          'color': const Color(0xFF8B5CF6),
          'badge': 'HD',
          'route': '/video_list',
        },
        {
          'title': 'Tanya AI Tutor',
          'icon': Icons.smart_toy_rounded,
          'color': const Color(0xFF10B981),
          'badge': '24/7',
          'route': '/ai_chat',
        },
      ],
    },
    {
      'category': 'Pencapaian & Evaluasi',
      'items': [
        {
          'title': 'Progress Belajar',
          'icon': Icons.insights_rounded,
          'color': const Color(0xFF10B981),
          'badge': '',
          'route': '/home',
        },
        {
          'title': 'Papan Skor',
          'icon': Icons.emoji_events_rounded,
          'color': const Color(0xFFF59E0B),
          'badge': 'TOP',
          'action': 'leaderboard',
        },
      ],
    },
    {
      'category': 'Transaksi & Pembayaran',
      'items': [
        {
          'title': 'Beli Paket',
          'icon': Icons.shopping_bag_rounded,
          'color': const Color(0xFF10B981),
          'badge': 'PROMO',
          'route': '/package_list',
        },
        {
          'title': 'Pesanan Saya',
          'icon': Icons.receipt_long_rounded,
          'color': const Color(0xFFF97316),
          'badge': '',
          'route': '/order_history',
        },
        {
          'title': 'Klaim Voucher',
          'icon': Icons.confirmation_number_rounded,
          'color': const Color(0xFF8B5CF6),
          'badge': 'HEMAT',
          'route': '/claim_voucher',
        },
        {
          'title': 'Keranjang Belanja',
          'icon': Icons.shopping_cart_rounded,
          'color': const Color(0xFF0284C7),
          'badge': '',
          'route': '/cart',
        },
      ],
    },
    {
      'category': 'Bantuan & Akun Siswa',
      'items': [
        {
          'title': 'Notifikasi',
          'icon': Icons.notifications_rounded,
          'color': const Color(0xFFF97316),
          'badge': '',
          'route': '/notification',
        },
        {
          'title': 'Profil Siswa',
          'icon': Icons.person_rounded,
          'color': const Color(0xFF06B6D4),
          'badge': '',
          'route': '/profile',
        },
        {
          'title': 'Pengaturan',
          'icon': Icons.settings_rounded,
          'color': const Color(0xFF64748B),
          'badge': '',
          'route': '/settings',
        },
        {
          'title': 'Bantuan CS',
          'icon': Icons.support_agent_rounded,
          'color': const Color(0xFF22C55E),
          'badge': 'WA',
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
          action == 'target_belajar'
              ? 'Target Belajar aktif kamu saat ini: Penguasaan Matematika Nalaria Realistik & Olimpiade Sains. Terus selesaikan latihan soal untuk meningkatkan skor!'
              : action == 'leaderboard'
                  ? 'Leaderboard Siswa KPM diperbarui secara berkala berdasarkan skor latihan & tryout resmi.'
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = _searchQuery.trim().toLowerCase();

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        leading: AppTheme.backButton(context),
        title: const Text('Semua Layanan & Fitur'),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Search Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCardColor : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  icon: const Icon(Icons.search_rounded, color: AppTheme.primaryBlue, size: 20),
                  hintText: 'Cari layanan atau fitur...',
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

            // 2. Render Categorized Features in 4-Column Grid
            ..._featureCategories.map((cat) {
              final List<Map<String, dynamic>> items = (cat['items'] as List<Map<String, dynamic>>)
                  .where((item) {
                    if (query.isEmpty) return true;
                    final title = (item['title'] as String).toLowerCase();
                    return title.contains(query);
                  })
                  .toList();

              if (items.isEmpty) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.bentoBoxDecoration(context: context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat['category'],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 4-Column Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.88,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final Color color = item['color'] as Color;

                        return GestureDetector(
                          onTap: () => _handleItemTap(item),
                          child: Column(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppTheme.darkBackgroundColor
                                          : color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isDark
                                            ? AppTheme.darkBorderColor
                                            : color.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Icon(item['icon'] as IconData, color: color, size: 22),
                                  ),
                                  if ((item['badge'] as String).isNotEmpty)
                                    Positioned(
                                      top: -3,
                                      right: -3,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: item['badge'] == 'HOT' || item['badge'] == 'LIVE'
                                              ? Colors.red
                                              : item['badge'] == 'NEW'
                                                  ? Colors.orange
                                                  : AppTheme.primaryBlue,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item['badge'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 7,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                item['title'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
