import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class TutorScreen extends StatefulWidget {
  const TutorScreen({super.key});

  @override
  State<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _liveClasses = [
    {
      'title': 'Live Class: Trik Cepat Matematika Nalaria Realistik (MNR)',
      'tutor': 'Dr. Ir. R. Ridwan Hasan Saputra, M.Si.',
      'role': 'Pakar Matematika & Pendiri KPM',
      'time': 'Hari Ini, 19:30 WIB',
      'badge': 'SEDANG BERLANGSUNG',
      'isLiveNow': true,
      'viewers': 342,
    },
    {
      'title': 'Bedah Soal Olimpiade Sains & MIPA Nasional',
      'tutor': 'Budi Pratama, M.Sc.',
      'role': 'Master Tutor Fisika & Sains KPM',
      'time': 'Besok, 16:00 WIB',
      'badge': 'JADWAL MENDATANG',
      'isLiveNow': false,
      'viewers': 180,
    },
    {
      'title': 'Pendalaman Aljabar & Geometri Tingkat Lanjut',
      'tutor': 'Siti Rahma, S.Si.',
      'role': 'Spesialis Pembinaan Olimpiade SMP & SMA',
      'time': 'Sabtu, 10:00 WIB',
      'badge': 'JADWAL MENDATANG',
      'isLiveNow': false,
      'viewers': 95,
    },
  ];

  final List<Map<String, dynamic>> _tutors = [
    {
      'name': 'Dr. Ir. R. Ridwan Hasan Saputra, M.Si.',
      'role': 'Master Coach Matematika Nalaria (MNR)',
      'exp': '25+ Thn Pengalaman',
      'rating': '5.0',
      'sessions': '3,500+ Sesi',
      'avatar': 'https://api.dicebear.com/7.x/adventurer/png?seed=Ridwan',
      'price': 'Rp 150rb/sesi',
      'tags': ['MNR', 'Olimpiade', 'Pelatihan Guru'],
    },
    {
      'name': 'Budi Pratama, M.Sc.',
      'role': 'Master Tutor Fisika & Sains Terapan',
      'exp': '10+ Thn Pengalaman',
      'rating': '4.9',
      'sessions': '1,420 Sesi',
      'avatar': 'https://api.dicebear.com/7.x/adventurer/png?seed=Budi',
      'price': 'Rp 120rb/sesi',
      'tags': ['Fisika SMA', 'Olimpiade Sains'],
    },
    {
      'name': 'Siti Rahma, S.Si.',
      'role': 'Spesialis Matematika SD & SMP',
      'exp': '8+ Thn Pengalaman',
      'rating': '4.9',
      'sessions': '1,150 Sesi',
      'avatar': 'https://api.dicebear.com/7.x/adventurer/png?seed=Siti',
      'price': 'Rp 100rb/sesi',
      'tags': ['Matematika SD', 'Logika Berhitung'],
    },
    {
      'name': 'Ahmad Fauzi, M.Pd.',
      'role': 'Tutor Kimia & Asesmen Sains',
      'exp': '7+ Thn Pengalaman',
      'rating': '4.8',
      'sessions': '890 Sesi',
      'avatar': 'https://api.dicebear.com/7.x/adventurer/png?seed=Fauzi',
      'price': 'Rp 100rb/sesi',
      'tags': ['Kimia Terapan', 'Eksperimen MIPA'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showBookingModal(Map<String, dynamic> tutor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardColor : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.backgroundColor,
                  backgroundImage: NetworkImage(tutor['avatar']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tutor['name'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        tutor['role'],
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Pilih Jenis Sesi Les Privat:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            _bookingOptionTile('Sesi 1-on-1 Online via Zoom (60 Menit)', 'Rp 150.000 / sesi', Icons.videocam_rounded),
            _bookingOptionTile('Paket Intensif 4 Sesi Pendampingan', 'Rp 500.000 (Hemat 15%)', Icons.card_giftcard_rounded),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Permintaan konsultasi dengan ${tutor['name']} telah dikirim! 🚀'),
                      backgroundColor: AppTheme.accentGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Konfirmasi & Hubungkan Tutor', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookingOptionTile(String title, String price, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primaryBlue)),
              ],
            ),
          ),
          const Icon(Icons.radio_button_checked_rounded, color: AppTheme.primaryBlue, size: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        leading: Navigator.canPop(context) ? AppTheme.backButton(context) : null,
        title: const Text('Live Class & Master Tutor'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: AppTheme.compactTabBar(
            controller: _tabController,
            tabs: const ['Live Class', 'Les Privat'],
            context: context,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLiveClassSection(isDark),
          _buildTutorSection(isDark),
        ],
      ),
    );
  }

  // Compact Modern Live Class Card
  Widget _buildLiveClassSection(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: _liveClasses.length,
      itemBuilder: (context, index) {
        final item = _liveClasses[index];
        final bool isLive = item['isLiveNow'] == true;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: AppTheme.bentoBoxDecoration(context: context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge row & viewer count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isLive ? Colors.redAccent.withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLive ? Icons.fiber_manual_record : Icons.schedule_rounded,
                          size: 10,
                          color: isLive ? Colors.redAccent : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['badge'],
                          style: TextStyle(
                            color: isLive ? Colors.redAccent : const Color(0xFF475569),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLive)
                    Row(
                      children: [
                        const Icon(Icons.remove_red_eye_rounded, size: 12, color: AppTheme.primaryBlue),
                        const SizedBox(width: 4),
                        Text(
                          '${item['viewers']} Peserta',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                item['title'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),

              // Tutor & Time info
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 14, color: AppTheme.primaryBlue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${item['tutor']} • ${item['role']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 14, color: AppTheme.kpmGold),
                  const SizedBox(width: 6),
                  Text(
                    item['time'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Action button
              SizedBox(
                width: double.infinity,
                height: 38,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLive ? AppTheme.primaryBlue : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                    foregroundColor: isLive ? Colors.white : (isDark ? Colors.white : AppTheme.textPrimary),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/video_player');
                  },
                  icon: Icon(isLive ? Icons.play_arrow_rounded : Icons.notifications_active_outlined, size: 16),
                  label: Text(
                    isLive ? 'Gabung Sesi Live' : 'Pasang Pengingat',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Compact Modern Tutor Card
  Widget _buildTutorSection(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: _tutors.length,
      itemBuilder: (context, index) {
        final tutor = _tutors[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: AppTheme.bentoBoxDecoration(context: context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    backgroundImage: NetworkImage(tutor['avatar']),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tutor['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          tutor['role'],
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.kpmGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 13, color: AppTheme.kpmGold),
                        const SizedBox(width: 2),
                        Text(
                          tutor['rating'],
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.kpmGold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Tags & price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tutor['sessions'],
                    style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                  ),
                  Text(
                    tutor['price'],
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          side: const BorderSide(color: AppTheme.primaryBlue),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/ai_chat'),
                        child: const Text('Tanya Profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () => _showBookingModal(tutor),
                        child: const Text('Booking Sesi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
