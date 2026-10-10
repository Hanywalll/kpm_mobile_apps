import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../models/banner_model.dart';
import '../../models/video_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/package_provider.dart';
import '../../providers/practice_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/dashboard_service.dart';
import '../../services/notification_service.dart';
import '../../services/video_service.dart';
import '../../widgets/auth_guard_bottom_sheet.dart';
import '../../widgets/custom_alert_dialog.dart';
import '../../widgets/permission_request_dialog.dart';
import '../../widgets/promo_poster_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _bannerController;
  final ValueNotifier<int> _bannerPageNotifier = ValueNotifier<int>(0);
  Timer? _autoSlideTimer;
  List<VideoModel> _recentVideos = [];
  bool _isLoadingVideos = false;
  List<BannerModel> _banners = DashboardService.getDefaultBanners();

  // 8 Essential KPM Function / Feature Menus (4x2 Kisi)
  static const List<Map<String, dynamic>> _learningGridItems = [
    {
      'title': 'Tryout CBT',
      'icon': Icons.quiz_rounded,
      'bgColor': Color(0xFFEFF6FF),
      'iconColor': Color(0xFF1D4ED8),
      'badge': 'IRT SKOR',
      'route': '/pretest',
      'protected': false,
    },
    {
      'title': 'Paket Belajar',
      'icon': Icons.school_rounded,
      'bgColor': Color(0xFFE0F2FE),
      'iconColor': Color(0xFF0284C7),
      'badge': 'LENGKAP',
      'route': '/package_list',
      'protected': false,
    },
    {
      'title': 'Live Class',
      'icon': Icons.live_tv_rounded,
      'bgColor': Color(0xFFFCE7F3),
      'iconColor': Color(0xFFDB2777),
      'badge': 'INTERAKTIF',
      'route': '/live_class',
      'protected': false,
    },
    {
      'title': 'Video Materi',
      'icon': Icons.play_circle_fill_rounded,
      'bgColor': Color(0xFFFEF3C7),
      'iconColor': Color(0xFFD97706),
      'badge': 'HD',
      'route': '/video_list',
      'protected': false,
    },
    {
      'title': 'Bank Soal',
      'icon': Icons.assignment_rounded,
      'bgColor': Color(0xFFEDE9FE),
      'iconColor': Color(0xFF7C3AED),
      'badge': 'MNR',
      'route': '/pretest',
      'protected': false,
    },
    {
      'title': 'Les Privat',
      'icon': Icons.person_search_rounded,
      'bgColor': Color(0xFFFFEDD5),
      'iconColor': Color(0xFFEA580C),
      'badge': '1-ON-1',
      'route': '/tutor',
      'protected': false,
    },
    {
      'title': 'Peringkat',
      'icon': Icons.leaderboard_rounded,
      'bgColor': Color(0xFFD1FAE5),
      'iconColor': Color(0xFF059669),
      'badge': 'TOP 10',
      'route': '/leaderboard',
      'protected': false,
    },
    {
      'title': 'Klaim Voucher',
      'icon': Icons.confirmation_number_rounded,
      'bgColor': Color(0xFFF1F5F9),
      'iconColor': Color(0xFF334155),
      'badge': 'DISKON',
      'route': '/claim_voucher',
      'protected': true,
    },
  ];

  // In-progress courses feed (KPM Nalaria & Sains)
  static const List<Map<String, dynamic>> _inProgressCourses = [
    {
      'title': 'Matematika Nalaria Realistik (MNR)',
      'subtitle': 'Bab 4: Logika Penalaran Soal Cerita',
      'category': 'Matematika Nalaria',
      'progress': 0.75,
      'points': '+100 Poin',
      'color': Color(0xFF1D4ED8),
      'route': '/package_list',
    },
    {
      'title': 'Simulasi CBT OSN Tingkat Provinsi',
      'subtitle': 'Sesi 2: Penalaran Eksplorasi Sains',
      'category': 'Olimpiade Sains',
      'progress': 0.60,
      'points': '+120 Poin',
      'color': Color(0xFF0284C7),
      'route': '/package_list',
    },
    {
      'title': 'Tanya AI Tutor & Bedah Soal',
      'subtitle': 'Konsultasi 24/7 Pembahasan MNR',
      'category': 'AI Tutor',
      'progress': 0.90,
      'points': '+80 Poin',
      'color': Color(0xFF7C3AED),
      'route': '/ai_chat',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController(initialPage: 0);
    _startAutoSlider();
    _loadBanners();
    _loadVideos();
    _loadUserProgress();
    _checkAndShowDialogs();
  }

  void _loadUserProgress() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final practice = Provider.of<PracticeProvider>(context, listen: false);
      if (auth.isAuthenticated) {
        practice.fetchStatistics();
        practice.fetchHistory();
      } else {
        practice.reset();
      }
    });
  }

  void _checkAndShowDialogs() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final shouldShowPermission = await PermissionRequestDialog.shouldShowDialog();
      if (shouldShowPermission && mounted) {
        await PermissionRequestDialog.show(context);
      }

      final shouldShowPromo = await PromoPosterDialog.shouldShowPromo();
      if (shouldShowPromo && mounted) {
        final promoBanner = _banners.isNotEmpty ? _banners.first : null;
        PromoPosterDialog.show(
          context,
          imageUrl: promoBanner?.imageUrl ??
              'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=800&auto=format&fit=crop&q=80',
          title: promoBanner?.title ?? 'Diskon Spesial Siswa KPM! 🎉',
          subtitle: promoBanner?.subtitle ??
              'Akses ribuan soal MNR, video materi, dan bimbingan AI Tutor 24/7 sekarang!',
          onAction: () {
            if (promoBanner != null &&
                promoBanner.route != null &&
                promoBanner.route!.isNotEmpty) {
              Navigator.pushNamed(context, promoBanner.route!);
            } else {
              Navigator.pushNamed(context, '/package_list');
            }
          },
        );
      }
    });
  }

  void _loadBanners() async {
    try {
      final dashboardService = Provider.of<DashboardService>(context, listen: false);
      final list = await dashboardService.getBanners();
      if (mounted && list.isNotEmpty) {
        setState(() {
          _banners = list;
        });
      }
    } catch (_) {}
  }

  void _loadVideos() async {
    setState(() => _isLoadingVideos = true);
    try {
      final videoService = Provider.of<VideoService>(context, listen: false);
      final list = await videoService.getVideos();
      if (mounted) {
        setState(() {
          _recentVideos = list.isNotEmpty ? list : VideoService.getDemoVideosList();
          _isLoadingVideos = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _recentVideos = VideoService.getDemoVideosList();
          _isLoadingVideos = false;
        });
      }
    }
  }

  void _startAutoSlider() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (mounted && _bannerController.hasClients && _bannerController.page != null) {
        final int nextPage = (_bannerController.page!.round() + 1) % _banners.length;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final packageProvider = Provider.of<PackageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.user;
    final isLoggedIn = authProvider.isAuthenticated;
    final String initialChar = (isLoggedIn && user?.fullName != null && user!.fullName.isNotEmpty)
        ? user.fullName[0].toUpperCase()
        : 'T';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Immersive white icons on deep blue
      ),
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackgroundColor : const Color(0xFFF8FAFC),
        body: Column(
          children: [
            // Prompt 1: Immersive Wave Header with Dynamic Theme Gradient
            _buildImmersiveHeader(context, initialChar, isLoggedIn, user?.fullName, user?.profilePhoto, packageProvider.cartCount, isDark, themeProvider),

            // Scrollable Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Admin Preview Indicator if admin
                    if (authProvider.isAdmin) _buildAdminPreviewBanner(),

                    const SizedBox(height: 12),

                    // Learning Wallet (Rebranded Gopay Card: Lanjut Belajar, Diskusi, Profil)
                    _buildLearningWalletCard(context, isDark, isLoggedIn),

                    const SizedBox(height: 18),

                    // Service Icons (4x2 Kisi KPM)
                    _buildLearningServiceGrid(isDark),

                    const SizedBox(height: 18),

                    // Prompt 1: Replicate Banner "Daftar 1 Kursus, Dapatkan 1 Webinar Gratis!"
                    _buildSpecialPromoBanner(context, isDark),

                    const SizedBox(height: 20),

                    // Prompt 1: "Lanjut Belajar" Feed (Mimicking GoFood Restaurant Feed)
                    _buildLanjutBelajarFeed(context, isDark),

                    const SizedBox(height: 20),

                    // Progres Belajar Statistik
                    _buildProgresBelajarCard(context, isDark, isLoggedIn),

                    const SizedBox(height: 20),

                    // Banner Promo Slider
                    _buildBannerSlider(),

                    const SizedBox(height: 20),

                    // Video Pembelajaran Terbaru
                    _buildRecentVideosSection(isDark),

                    const SizedBox(height: 20),

                    // Paket Belajar Unggulan
                    _buildFeaturedPackagesSection(packageProvider, isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Floating Action Button KPM AI Deep Blue
        floatingActionButton: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF092957), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D4ED8).withValues(alpha: 0.4),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                AuthGuard.check(
                  context,
                  featureName: 'KPM AI Tutor',
                  onAuthenticated: () => Navigator.pushNamed(context, '/ai_chat'),
                );
              },
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                  SizedBox(height: 2),
                  Text(
                    'Tanya',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 9.5,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TOP IMMERSIVE HEADER (FLAT / DATAR CLEAN EDGE)
  // ==========================================
  Widget _buildImmersiveHeader(
    BuildContext context,
    String initialChar,
    bool isLoggedIn,
    String? fullName,
    String? profilePhoto,
    int cartCount,
    bool isDark,
    ThemeProvider themeProvider,
  ) {
    ImageProvider? avatarImg;
    if (profilePhoto != null && profilePhoto.trim().isNotEmpty) {
      if (profilePhoto.startsWith('http://') || profilePhoto.startsWith('https://')) {
        avatarImg = NetworkImage(profilePhoto);
      } else {
        final f = File(profilePhoto);
        if (f.existsSync()) {
          avatarImg = FileImage(f);
        } else {
          avatarImg = NetworkImage(profilePhoto);
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: themeProvider.headerGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
              children: [
                // Top Row: Avatar & Greeting, Cart, Notifications
                Row(
                  children: [
                    // Profile Avatar & Greeting
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (isLoggedIn) {
                            Navigator.pushNamed(context, '/profile');
                          } else {
                            Navigator.pushNamed(context, '/login');
                          }
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                              ),
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFF2563EB),
                                backgroundImage: isLoggedIn ? avatarImg : null,
                                child: (isLoggedIn && avatarImg == null)
                                    ? Text(
                                        initialChar,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      )
                                    : (isLoggedIn
                                        ? null
                                        : const Icon(Icons.person_rounded, color: Colors.white, size: 20)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (isLoggedIn) ...[
                                    Text(
                                      'Halo, ${fullName ?? "Siswa KPM"} 👋',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Semangat belajar hari ini!',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: Colors.white.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ] else ...[
                                    Row(
                                      children: [
                                        Text(
                                          'Masuk / Daftar',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.white),
                                      ],
                                    ),
                                    Text(
                                      'Akses materi & simulasi ujian',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        color: Colors.white.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Cart Icon with white contrast
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/cart'),
                      icon: Badge(
                        isLabelVisible: cartCount > 0,
                        label: Text('$cartCount'),
                        backgroundColor: Colors.redAccent,
                        child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 22),
                      ),
                      tooltip: 'Keranjang',
                    ),

                    // Notification Icon with white contrast
                    Consumer<NotificationService>(
                      builder: (context, notifService, _) {
                        final unreadCount = notifService.unreadCount;
                        return IconButton(
                          onPressed: () => Navigator.pushNamed(context, '/notification'),
                          icon: Badge(
                            isLabelVisible: unreadCount > 0,
                            label: Text('$unreadCount'),
                            backgroundColor: Colors.redAccent,
                            child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                          ),
                          tooltip: 'Notifikasi',
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Prompt 1: Search Bar ("Belajar Apa Hari Ini?")
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/search'),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Color(0xFF1D4ED8), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Belajar Apa Hari Ini?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Cari',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  // ==========================================
  // PROMPT 1: LEARNING WALLET (Rebranded Gopay Card)
  // White background, blue icons, Poin Belajar & Tiket Webinar, Absen/Diskusi/Profil
  // ==========================================
  Widget _buildLearningWalletCard(BuildContext context, bool isDark, bool isLoggedIn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: AppTheme.neumorphicBoxDecoration(
          context: context,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Left: Wallet Balance & Tickets
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.monetization_on_rounded, color: Color(0xFF2563EB), size: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Poin Belajar: 23,400',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined, color: Color(0xFF0284C7), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '30 Tiket Webinar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Divider vertical
            Container(
              height: 38,
              width: 1,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),

            // Right: 3 Learning Actions (Absen, Diskusi, Profil)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWalletActionButton(
                  icon: Icons.play_lesson_rounded,
                  label: 'Lanjut',
                  onTap: () {
                    AuthGuard.check(
                      context,
                      featureName: 'Lanjut Belajar',
                      onAuthenticated: () {
                        final packageProvider = Provider.of<PackageProvider>(context, listen: false);
                        if (packageProvider.enrolledPackages.isNotEmpty) {
                          final lastPkg = packageProvider.enrolledPackages.first;
                          packageProvider.fetchPackageDetail(lastPkg.id);
                          Navigator.pushNamed(context, '/package_detail', arguments: lastPkg);
                        } else {
                          Navigator.pushNamed(context, '/package_list');
                        }
                      },
                    );
                  },
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _buildWalletActionButton(
                  icon: Icons.forum_rounded,
                  label: 'Diskusi',
                  onTap: () {
                    AuthGuard.check(
                      context,
                      featureName: 'Forum Diskusi',
                      onAuthenticated: () => Navigator.pushNamed(context, '/discussion'),
                    );
                  },
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _buildWalletActionButton(
                  icon: Icons.person_rounded,
                  label: 'Profil',
                  onTap: () {
                    if (isLoggedIn) {
                      Navigator.pushNamed(context, '/profile');
                    } else {
                      Navigator.pushNamed(context, '/login');
                    }
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1D4ED8), size: 19),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PROMPT 1: 8 SERVICE GRID (4x2 Kisi)
  // Categories: AI Basic, Coding, Design, Business, Language, Webinar, Sertifikat, Lainnya
  // Features: Rounded white rectangle with blue background highlight,
  // Tiny blue "learning hat" flag at top-left, small red NEW! / PROMO flags.
  // ==========================================
  Widget _buildLearningServiceGrid(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _learningGridItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 14,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final item = _learningGridItems[index];
          return _buildGridServiceItem(item, isDark);
        },
      ),
    );
  }

  Widget _buildGridServiceItem(Map<String, dynamic> item, bool isDark) {
    final IconData icon = item['icon'] as IconData;
    final Color bgColor = item['bgColor'] as Color;
    final Color iconColor = item['iconColor'] as Color;
    final String title = item['title'] as String;
    final String route = item['route'] as String;
    final String? badge = item['badge'] as String?;
    final bool isProtected = item['protected'] as bool;

    return GestureDetector(
      onTap: () {
        if (isProtected) {
          AuthGuard.check(
            context,
            featureName: title,
            onAuthenticated: () => Navigator.pushNamed(context, route),
          );
        } else {
          Navigator.pushNamed(context, route);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rounded rectangle box with tiny learning hat flag top-left
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFEFF6FF),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? bgColor.withValues(alpha: 0.15) : bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                ),
              ),

              // Tiny blue "learning hat" flag at top-left
              Positioned(
                top: -3,
                left: -3,
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D4ED8), // Royal Blue Hat Flag
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 9,
                  ),
                ),
              ),

              // Small red "NEW!" or "PROMO" or "-50%" flag badge
              if (badge != null)
                Positioned(
                  top: -5,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PROMPT 1: SPECIAL PROMO BANNER
  // "Daftar 1 Kursus, Dapatkan 1 Webinar Gratis!"
  // ==========================================
  Widget _buildSpecialPromoBanner(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/package_list'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F3E7D), Color(0xFF1D4ED8)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D4ED8).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.card_giftcard_rounded, color: Colors.amberAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROMO SPESIAL BULAN INI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.amberAccent,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Daftar 1 Kursus, Dapatkan 1 Webinar Gratis!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Klaim',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // PROMPT 1: "LANJUT BELAJAR" FEED
  // (Mimicking GoFood Restaurant Feed with Progress Bar & Floating Coin Rewards)
  // ==========================================
  Widget _buildLanjutBelajarFeed(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.play_circle_filled_rounded, color: Color(0xFF1D4ED8), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Lanjut Belajar',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/package_list'),
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 148,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _inProgressCourses.length,
            itemBuilder: (context, index) {
              final course = _inProgressCourses[index];
              final double progress = course['progress'] as double;

              return GestureDetector(
                onTap: () => Navigator.pushNamed(context, course['route'] as String),
                child: Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: AppTheme.neumorphicBoxDecoration(
                    context: context,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Category badge & Floating Coin Reward Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (course['color'] as Color).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              course['category'] as String,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: course['color'] as Color,
                              ),
                            ),
                          ),
                          // Floating coin rewards badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.monetization_on_rounded, size: 11, color: Color(0xFFD97706)),
                                const SizedBox(width: 3),
                                Text(
                                  course['points'] as String,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Course Title & Subtitle
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course['title'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            course['subtitle'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      // Progress Bar & Percentage
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progres Belajar',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation<Color>(course['color'] as Color),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // PROGRESS BELAJAR CARD
  // ==========================================
  Widget _buildProgresBelajarCard(BuildContext context, bool isDark, bool isLoggedIn) {
    final practiceProvider = Provider.of<PracticeProvider>(context);
    final stats = practiceProvider.statistics;
    final double averageScore = isLoggedIn ? (stats?.avgScore ?? 0.0) : 0.0;
    final int totalPractice = isLoggedIn ? (stats?.totalSessions ?? practiceProvider.history.length) : 0;
    final int correctAnswers = isLoggedIn ? (stats?.totalCorrect ?? 0) : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: AppTheme.neumorphicBoxDecoration(
          context: context,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D4ED8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'STATISTIK BELAJAR',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D4ED8),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rata-rata: ${averageScore.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$totalPractice Sesi • $correctAnswers Soal Benar',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _progresActionButton(
                  icon: Icons.play_arrow_rounded,
                  label: 'Latihan',
                  bgColor: const Color(0xFFE0E7FF),
                  iconColor: const Color(0xFF4338CA),
                  onTap: () {
                    AuthGuard.check(
                      context,
                      featureName: 'Latihan Ujian',
                      onAuthenticated: () => Navigator.pushNamed(context, '/package_list'),
                    );
                  },
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _progresActionButton(
                  icon: Icons.insert_chart_outlined_rounded,
                  label: 'Rapor',
                  bgColor: const Color(0xFFE0F2FE),
                  iconColor: const Color(0xFF0284C7),
                  onTap: () {
                    AuthGuard.check(
                      context,
                      featureName: 'Rapor Skor',
                      onAuthenticated: () => Navigator.pushNamed(context, '/result'),
                    );
                  },
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _progresActionButton(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Beli',
                  bgColor: const Color(0xFFFFEDD5),
                  iconColor: const Color(0xFFEA580C),
                  onTap: () => Navigator.pushNamed(context, '/package_list'),
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _progresActionButton({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? bgColor.withValues(alpha: 0.15) : bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BANNER SLIDER
  // ==========================================
  Widget _buildBannerSlider() {
    return Column(
      children: [
        SizedBox(
          height: 155,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _banners.length,
            onPageChanged: (idx) => _bannerPageNotifier.value = idx,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              final String imageUrl = banner.imageUrl;

              return GestureDetector(
                onTap: () {
                  if (banner.route != null && banner.route!.isNotEmpty) {
                    Navigator.pushNamed(context, banner.route!);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imageUrl.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              decoration: const BoxDecoration(gradient: AppTheme.blueGradient),
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: const BoxDecoration(gradient: AppTheme.blueGradient),
                            ),
                          )
                        else
                          Container(decoration: const BoxDecoration(gradient: AppTheme.blueGradient)),

                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.black.withValues(alpha: 0.15),
                                Colors.black.withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.22),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.8),
                                    ),
                                    child: Text(
                                      banner.tag,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    banner.subTag,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    banner.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    banner.subtitle,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<int>(
          valueListenable: _bannerPageNotifier,
          builder: (context, activeIndex, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _banners.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: activeIndex == i ? 18 : 6,
                  height: 5,
                  decoration: BoxDecoration(
                    color: activeIndex == i ? const Color(0xFF1D4ED8) : Colors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ==========================================
  // RECENT VIDEOS SECTION
  // ==========================================
  Widget _buildRecentVideosSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Video Pembelajaran Terbaru',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF0F172A),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/video_list'),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (_isLoadingVideos && _recentVideos.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          SizedBox(
            height: 162,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _recentVideos.length,
              itemBuilder: (context, index) {
                final video = _recentVideos[index];
                final String thumbUrl = video.safeThumbnailUrl;

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/video_player', arguments: video);
                  },
                  child: Container(
                    width: 210,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: AppTheme.neumorphicBoxDecoration(
                      context: context,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: SizedBox(
                            height: 96,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (thumbUrl.isNotEmpty)
                                  CachedNetworkImage(
                                    imageUrl: thumbUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      decoration: BoxDecoration(
                                        gradient: index % 2 == 0 ? AppTheme.ruangguruGradient : AppTheme.purpleGradient,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      decoration: BoxDecoration(
                                        gradient: index % 2 == 0 ? AppTheme.ruangguruGradient : AppTheme.purpleGradient,
                                      ),
                                      child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 28),
                                    ),
                                  )
                                else
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: index % 2 == 0 ? AppTheme.ruangguruGradient : AppTheme.purpleGradient,
                                    ),
                                  ),
                                Container(
                                  color: Colors.black.withValues(alpha: 0.2),
                                ),
                                Center(
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.55),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                                    ),
                                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                                  ),
                                ),
                                Positioned(
                                  bottom: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      video.durationFormatted,
                                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                video.description.isNotEmpty ? video.description : 'Video Pembelajaran MIPA',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ==========================================
  // FEATURED PACKAGES SECTION
  // ==========================================
  Widget _buildFeaturedPackagesSection(PackageProvider packageProvider, bool isDark) {
    final packages = packageProvider.packages;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paket Belajar Unggulan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF0F172A),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/package_list'),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (packages.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text('Memuat paket belajar...', style: TextStyle(fontSize: 12, color: Colors.grey)),
          )
        else
          ...packages.take(2).map((pkg) {
            final isInCart = packageProvider.isInCart(pkg.id);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(14),
              decoration: AppTheme.neumorphicBoxDecoration(
                context: context,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF092957), Color(0xFF1D4ED8)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1D4ED8).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${pkg.jenjang} ${pkg.kelas}',
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pkg.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${pkg.activeDays} Hari Akses • ${pkg.totalModules} Modul',
                    style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (pkg.hasDiscount)
                            Text(
                              Formatter.currency(pkg.price),
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontSize: 10,
                                color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                              ),
                            ),
                          Text(
                            Formatter.currency(pkg.effectivePrice),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1D4ED8)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: 34,
                            width: 34,
                            decoration: BoxDecoration(
                              color: isInCart
                                  ? AppTheme.accentGreen.withValues(alpha: 0.12)
                                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isInCart ? AppTheme.accentGreen : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              ),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                final added = packageProvider.toggleCart(pkg);
                                if (added) {
                                  AppModal.showCartSuccess(
                                    context,
                                    package: pkg,
                                    onGoToCart: () => Navigator.pushNamed(context, '/cart'),
                                  );
                                } else {
                                  AppModal.showInfo(
                                    context,
                                    title: 'Dihapus dari Keranjang',
                                    message: '${pkg.title} telah dihapus dari keranjang.',
                                  );
                                }
                              },
                              icon: Icon(
                                isInCart ? Icons.shopping_cart_rounded : Icons.add_shopping_cart_rounded,
                                color: isInCart ? AppTheme.accentGreen : const Color(0xFF1D4ED8),
                                size: 17,
                              ),
                              tooltip: 'Keranjang',
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D4ED8),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              minimumSize: const Size(0, 34),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/package_detail', arguments: pkg);
                            },
                            child: const Text('Detail', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildAdminPreviewBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.admin_panel_settings_rounded, color: Colors.amberAccent, size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode Tinjauan Siswa',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  'Anda sedang melihat tampilan dashboard siswa.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade400,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/admin_dashboard', (r) => false),
            child: const Text('Panel CMS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
