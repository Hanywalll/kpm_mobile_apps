import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_guard_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _bannerController;
  final ValueNotifier<int> _bannerPageNotifier = ValueNotifier<int>(0);
  Timer? _autoSlideTimer;

  static const List<Map<String, dynamic>> _quickActions = [
    {
      'title': 'Tryout CBT',
      'badge': '-50%',
      'icon': Icons.assignment_rounded,
      'color': Color(0xFFFF6B6B),
      'route': '/package_list',
    },
    {
      'title': 'Live Class',
      'badge': 'LIVE',
      'icon': Icons.video_camera_front_rounded,
      'color': Color(0xFF2196F3),
      'route': '/video_list',
    },
    {
      'title': 'AI Tutor',
      'badge': '24/7',
      'icon': Icons.smart_toy_rounded,
      'color': Color(0xFF9C27B0),
      'route': '/ai_chat',
    },
    {
      'title': 'Enroll Key',
      'badge': 'KLAIM',
      'icon': Icons.vpn_key_rounded,
      'color': Color(0xFF00B894),
      'route': '/enroll_key',
    },
    {
      'title': 'Bank Soal',
      'badge': 'NEW',
      'icon': Icons.menu_book_rounded,
      'color': Color(0xFFFF9F43),
      'route': '/package_list',
    },
    {
      'title': 'Beli Paket',
      'badge': 'PROMO',
      'icon': Icons.card_membership_rounded,
      'color': Color(0xFF0ABDE3),
      'route': '/package_list',
    },
    {
      'title': 'Rapor IRT',
      'badge': 'SCORE',
      'icon': Icons.analytics_rounded,
      'color': Color(0xFFEE5253),
      'route': '/result',
    },
    {
      'title': 'Lainnya',
      'badge': '',
      'icon': Icons.grid_view_rounded,
      'color': Color(0xFF5F27CD),
      'route': 'sheet',
    },
  ];

  static const List<Map<String, dynamic>> _allFeatures = [
    {
      'title': 'Tryout IRT',
      'badge': 'HOT',
      'icon': Icons.assignment_rounded,
      'color': Color(0xFFFF6B6B),
      'route': '/package_list',
    },
    {
      'title': 'Live Class',
      'badge': 'LIVE',
      'icon': Icons.video_camera_front_rounded,
      'color': Color(0xFF2196F3),
      'route': '/video_list',
    },
    {
      'title': 'AI Tutor',
      'badge': '24/7',
      'icon': Icons.smart_toy_rounded,
      'color': Color(0xFF9C27B0),
      'route': '/ai_chat',
    },
    {
      'title': 'Beli Paket',
      'badge': 'PROMO',
      'icon': Icons.card_membership_rounded,
      'color': Color(0xFF0ABDE3),
      'route': '/package_list',
    },
    {
      'title': 'Bank Soal',
      'badge': 'NEW',
      'icon': Icons.menu_book_rounded,
      'color': Color(0xFFFF9F43),
      'route': '/package_list',
    },
    {
      'title': 'Enroll Key',
      'badge': 'KLAIM',
      'icon': Icons.vpn_key_rounded,
      'color': Color(0xFF00B894),
      'route': '/enroll_key',
    },
    {
      'title': 'Rapor IRT',
      'badge': 'SCORE',
      'icon': Icons.analytics_rounded,
      'color': Color(0xFFEE5253),
      'route': '/result',
    },
    {
      'title': 'Kelas Saya',
      'badge': '',
      'icon': Icons.auto_stories_rounded,
      'color': Color(0xFF10AC84),
      'route': '/home',
    },
    {
      'title': 'Video Rekaman',
      'badge': '',
      'icon': Icons.play_circle_fill_rounded,
      'color': Color(0xFF5F27CD),
      'route': '/video_list',
    },
    {
      'title': 'Simulasi SNBT',
      'badge': '2025',
      'icon': Icons.school_rounded,
      'color': Color(0xFFE91E63),
      'route': '/pretest',
    },
    {
      'title': 'Notifikasi',
      'badge': '',
      'icon': Icons.notifications_rounded,
      'color': Color(0xFFF368E0),
      'route': '/notification',
    },
    {
      'title': 'Pengaturan',
      'badge': '',
      'icon': Icons.settings_rounded,
      'color': Color(0xFF576574),
      'route': '/settings',
    },
  ];

  static const List<Map<String, dynamic>> _banners = [
    // 1. BANNER 1: PROMO KELAS & DISKON HARGA
    {
      'title': 'Bimbel Intensif UTBK & SNBT 2025',
      'badge': '⚡ FLASH SALE',
      'discount': 'DISKON 70%',
      'price': 'Rp 149.000',
      'originalPrice': 'Rp 499.000',
      'sub': 'Akses 50x Tryout IRT & Ribuan Video Pembelajaran',
      'gradient': AppTheme.ruangguruGradient,
      'image': 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=1000&auto=format&fit=crop&q=80',
    },
    // 2. BANNER 2: KEGIATAN TERBARU
    {
      'title': 'Tryout Akbar Nasional SNBT 2025',
      'badge': '📅 KEGIATAN TERBARU',
      'tag': '🔥 15.000+ PESERTA',
      'tagColor': Color(0xFFFF9F43),
      'highlight': '🗓️ Live Simulasi: Sabtu - Minggu Ini',
      'sub': 'Simulasi Sistem IRT Resmi & Ranking Nasional Serentak',
      'gradient': AppTheme.orangeGradient,
      'image': 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=1000&auto=format&fit=crop&q=80',
    },
    // 3. BANNER 3: KELAS TERBARU
    {
      'title': 'Kelas Baru: Master Penalaran & TPS',
      'badge': '✨ KELAS TERBARU',
      'tag': '⭐ KURIKULUM 2025',
      'tagColor': Color(0xFF00B894),
      'highlight': '👨‍🏫 Dibimbing Langsung Tutor Master PTN',
      'sub': 'Bimbingan Interaktif + Tanya AI Tutor Cerdas 24/7',
      'gradient': AppTheme.purpleGradient,
      'image': 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=1000&auto=format&fit=crop&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(initialPage: 0);
    _startAutoSlider();
  }

  void _startAutoSlider() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _bannerController.hasClients && _bannerController.page != null) {
        final int nextPage = (_bannerController.page!.round() + 1) % _banners.length;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _bannerController.dispose();
    _bannerPageNotifier.dispose();
    super.dispose();
  }

  void _showAllFeaturesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.72,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Semua Layanan & Fitur 🚀',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pusat akses belajar dan persiapan ujian',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                physics: const BouncingScrollPhysics(),
                itemCount: _allFeatures.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  final item = _allFeatures[index];
                  return _buildFeatureGridItem(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGridItem(Map<String, dynamic> item) {
    final route = item['route'] as String;
    final isProtected = ['/ai_chat', '/enroll_key', '/result', '/settings', '/pretest'].contains(route);

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (isProtected) {
          AuthGuard.check(
            context,
            featureName: item['title'],
            onAuthenticated: () => Navigator.pushNamed(context, route),
          );
        } else {
          Navigator.pushNamed(context, route);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: (item['color'] as Color).withOpacity(0.25),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (item['color'] as Color).withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                  size: 26,
                ),
              ),
              if (item['badge'] != null && (item['badge'] as String).isNotEmpty)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3838),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      item['badge'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['title'] as String,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final bool isLoggedIn = auth.isAuthenticated;
    final String initialChar = (user?.fullName != null && user!.fullName.isNotEmpty)
        ? user.fullName[0].toUpperCase()
        : 'S';
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Edge-to-Edge Hero Header Display (Gojek Immersive Style)
            _buildEdgeToEdgeHeroHeader(initialChar, statusBarHeight, isLoggedIn),

            // 2. Overlapping Academic Card (Target PTN & Level Siswa)
            Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.12), shape: BoxShape.circle),
                        child: const Icon(Icons.stars_rounded, color: AppTheme.primaryBlue, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!isLoggedIn) {
                              AuthGuard.check(
                                context,
                                featureName: 'Target PTN Impian',
                                onAuthenticated: () {},
                              );
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isLoggedIn ? 'Target PTN Impian' : 'Siswa KPM Academy',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              Text(
                                isLoggedIn ? 'ITB / UI SNBT 2025' : 'Yuk, Masuk / Daftar Akun',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              ),
                              Text(
                                isLoggedIn
                                    ? '450 XP Points ⭐ • Level Master'
                                    : 'Simpan target PTN & kumpulkan XP 🚀',
                                style: const TextStyle(fontSize: 10, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _academicActionButton(
                        Icons.vpn_key_rounded,
                        'Klaim Key',
                        () => AuthGuard.check(
                          context,
                          featureName: 'Klaim Enroll Key',
                          onAuthenticated: () => Navigator.pushNamed(context, '/enroll_key'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _academicActionButton(
                        Icons.analytics_rounded,
                        'Rapor IRT',
                        () => AuthGuard.check(
                          context,
                          featureName: 'Rapor Nilai IRT',
                          onAuthenticated: () => Navigator.pushNamed(context, '/result'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _academicActionButton(Icons.grid_view_rounded, 'Lainnya', _showAllFeaturesSheet),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Quick Actions Grid Services (4x2 Gojek Grid)
            Transform.translate(
              offset: const Offset(0, -16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _quickActions.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemBuilder: (context, index) {
                    final item = _quickActions[index];
                    return _buildGojekServiceItem(item);
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 4. Promo Offer Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppTheme.emeraldGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Mau tryout & live class lebih hemat?\nBeli Paket Belajar Sekarang ➔',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/package_list'),
                      child: const Text('Beli', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 5. Lanjutkan Belajar Kamu Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lanjutkan Belajar Kamu 🎓', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 170,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _continueStudyCard('Lanjutkan Bab 19: Logaritma', 'Kelas TPS Kuantitatif • 90% Selesai', AppTheme.ruangguruGradient),
                        _continueStudyCard('Soal Harian: Vektor & Kinematika', 'Kelas Fisika MIPA • 66% Selesai', AppTheme.purpleGradient),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEdgeToEdgeHeroHeader(String initialChar, double statusBarHeight, bool isLoggedIn) {
    final double headerHeight = statusBarHeight + 225.0;

    return SizedBox(
      height: headerHeight,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Full-Bleed Hero Banner Slider (Langsung Menjadi Background Utama Menembus Status Bar)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
            child: SizedBox(
              height: headerHeight,
              width: double.infinity,
              child: PageView.builder(
                controller: _bannerController,
                onPageChanged: (idx) {
                  _bannerPageNotifier.value = idx;
                },
                itemCount: _banners.length,
                itemBuilder: (context, index) {
                  final b = _banners[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // 1. Full Image Background (Menutupi seluruh area banner hingga tembus ke notifikasi HP)
                      Image.network(
                        b['image'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: headerHeight,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            decoration: BoxDecoration(gradient: b['gradient']),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(gradient: b['gradient']),
                          );
                        },
                      ),

                      // 2. Cinematic Gradient Overlay (Menjamin teks promo & search bar sangat tajam dan kontras)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.50), // Perlindungan area status bar & search bar
                              Colors.black.withOpacity(0.20),
                              Colors.black.withOpacity(0.75), // Perlindungan area teks judul & dots
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),

                      // 3. Konten Teks Banner (Badge, Judul, Harga Diskon, Subtitle)
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pushNamed(context, '/package_list'),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                20,
                                statusBarHeight + 64, // Di bawah floating search bar
                                20,
                                36, // Di atas area overlapping card & dots
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.25),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                                        ),
                                        child: Text(
                                          b['badge'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      if (b['discount'] != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF3838),
                                            borderRadius: BorderRadius.circular(6),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            b['discount'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ] else if (b['tag'] != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: (b['tagColor'] as Color? ?? Colors.amber).withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(6),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.25),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            b['tag'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    b['title'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      height: 1.15,
                                      shadows: [
                                        Shadow(color: Colors.black87, offset: Offset(0, 2), blurRadius: 4),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (b['price'] != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          b['price'],
                                          style: const TextStyle(
                                            color: Color(0xFFFFE600),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            shadows: [
                                              Shadow(color: Colors.black87, offset: Offset(0, 1), blurRadius: 4),
                                            ],
                                          ),
                                        ),
                                        if (b['originalPrice'] != null) ...[
                                          const SizedBox(width: 8),
                                          Text(
                                            b['originalPrice'],
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.75),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              decoration: TextDecoration.lineThrough,
                                              decorationColor: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ] else if (b['highlight'] != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.35),
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.8),
                                          ),
                                          child: Text(
                                            b['highlight'],
                                            style: const TextStyle(
                                              color: Color(0xFFFFE600),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    b['sub'],
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.95),
                                      fontSize: 11,
                                      shadows: const [
                                        Shadow(color: Colors.black54, offset: Offset(0, 1), blurRadius: 3),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // 2. Floating Search & Profile Bar (Melayang di Atas Banner seperti Gojek)
          Positioned(
            top: statusBarHeight + 6,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search_rounded, color: Colors.grey, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Cari materi, tryout, atau tutor...',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => AuthGuard.check(
                    context,
                    featureName: 'Klaim XP Harian',
                    onAuthenticated: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎉 Selamat! Kamu mendapatkan +20 XP hari ini!'),
                          backgroundColor: Color(0xFF00B894),
                        ),
                      );
                    },
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Ambil XP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    if (isLoggedIn) {
                      Navigator.pushNamed(context, '/settings');
                    } else {
                      AuthGuard.check(
                        context,
                        featureName: 'Profil & Pengaturan',
                        onAuthenticated: () => Navigator.pushNamed(context, '/settings'),
                      );
                    }
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: isLoggedIn ? AppTheme.primaryBlue : Colors.grey.shade400,
                      child: isLoggedIn
                          ? Text(
                              initialChar,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Dots Indicator (Tepat di bagian bawah banner)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<int>(
              valueListenable: _bannerPageNotifier,
              builder: (context, currentIdx, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _banners.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 5,
                      width: currentIdx == index ? 18 : 5,
                      decoration: BoxDecoration(
                        color: currentIdx == index ? Colors.white : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _academicActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: AppTheme.backgroundColor, shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 18),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildGojekServiceItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        if (item['route'] == 'sheet') {
          _showAllFeaturesSheet();
        } else if (['/ai_chat', '/enroll_key', '/result'].contains(item['route'])) {
          AuthGuard.check(
            context,
            featureName: item['title'],
            onAuthenticated: () => Navigator.pushNamed(context, item['route']),
          );
        } else {
          Navigator.pushNamed(context, item['route']);
        }
      },
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 56,
                width: 58,
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(item['icon'], color: item['color'], size: 28),
              ),
              if ((item['badge'] as String).isNotEmpty)
                Positioned(
                  top: -6,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item['badge'],
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item['title'],
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _continueStudyCard(String title, String sub, Gradient gradient) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryBlue,
                minimumSize: const Size(0, 30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              onPressed: () => Navigator.pushNamed(context, '/package_detail'),
              child: const Text('Buka', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}
