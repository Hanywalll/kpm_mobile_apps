import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../models/banner_model.dart';
import '../../models/package_model.dart';
import '../../models/video_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/package_provider.dart';
import '../../providers/practice_provider.dart';
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

  // 8 Menu Actions matched exactly with user's design reference
  static const List<Map<String, dynamic>> _quickActions = [
    {
      'title': 'Paket Belajar',
      'icon': Icons.menu_book_rounded,
      'bgColor': Color(0xFFDBEAFE),
      'iconColor': Color(0xFF1D4ED8),
      'route': '/package_list',
      'protected': false,
    },
    {
      'title': 'Latihan Ujian',
      'icon': Icons.assignment_outlined,
      'bgColor': Color(0xFFE0F2FE),
      'iconColor': Color(0xFF0284C7),
      'route': '/package_list',
      'protected': true,
    },
    {
      'title': 'Video Materi',
      'icon': Icons.play_circle_fill_rounded,
      'bgColor': Color(0xFFEDE9FE),
      'iconColor': Color(0xFF7C3AED),
      'route': '/video_list',
      'protected': false,
    },
    {
      'title': 'Rapor Skor',
      'icon': Icons.analytics_rounded,
      'bgColor': Color(0xFFFEF3C7),
      'iconColor': Color(0xFFD97706),
      'route': '/result',
      'protected': true,
    },
    {
      'title': 'Pesanan Saya',
      'icon': Icons.receipt_long_rounded,
      'bgColor': Color(0xFFFFEDD5),
      'iconColor': Color(0xFFEA580C),
      'route': '/order_history',
      'protected': true,
    },
    {
      'title': 'Live Class',
      'icon': Icons.live_tv_rounded,
      'bgColor': Color(0xFFFCE7F3),
      'iconColor': Color(0xFFDB2777),
      'route': '/live_class',
      'protected': false,
    },
    {
      'title': 'Beli Paket',
      'icon': Icons.shopping_bag_rounded,
      'bgColor': Color(0xFFD1FAE5),
      'iconColor': Color(0xFF059669),
      'route': '/package_list',
      'protected': false,
    },
    {
      'title': 'Lainnya',
      'icon': Icons.grid_view_rounded,
      'bgColor': Color(0xFFF1F5F9),
      'iconColor': Color(0xFF334155),
      'route': '/all_features',
      'protected': false,
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
      // 1. Show standard app permission request dialog on first launch
      final shouldShowPermission = await PermissionRequestDialog.shouldShowDialog();
      if (shouldShowPermission && mounted) {
        await PermissionRequestDialog.show(context);
      }

      // 2. Show promo poster popup if 2 hours have passed
      final shouldShowPromo = await PromoPosterDialog.shouldShowPromo();
      if (shouldShowPromo && mounted) {
        final promoBanner = _banners.isNotEmpty ? _banners.first : null;
        PromoPosterDialog.show(
          context,
          imageUrl: promoBanner?.imageUrl ?? 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=800&auto=format&fit=crop&q=80',
          title: promoBanner?.title ?? 'Diskon Spesial Siswa KPM! 🎉',
          subtitle: promoBanner?.subtitle ?? 'Akses ribuan soal MNR, video materi, dan bimbingan AI Tutor 24/7 sekarang!',
          onAction: () {
            if (promoBanner != null && promoBanner.route != null && promoBanner.route!.isNotEmpty) {
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

  // Auto-slide every 8 seconds
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
    final user = authProvider.user;
    final isLoggedIn = authProvider.isAuthenticated;
    final String initialChar = (isLoggedIn && user?.fullName != null && user!.fullName.isNotEmpty)
        ? user.fullName[0].toUpperCase()
        : 'T';

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Fixed Top Header (Greeting, Avatar, Cart, Notifications)
            _buildModernHeader(context, initialChar, isLoggedIn, user?.fullName, user?.profilePhoto, packageProvider.cartCount, isDark),

            // 2. Scrollable Body (ClampingScrollPhysics to prevent excessive overscroll)
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    // 2. Banner Slider with Image Background & 8-second interval
                    _buildBannerSlider(),

            const SizedBox(height: 12),

            // 3. Progres Belajar Card (Rata-rata score, Latihan count, and 3 buttons: Latihan, Rapor, Beli)
            _buildProgresBelajarCard(context, isDark, isLoggedIn),

            const SizedBox(height: 10),

            // 4. Search Bar with "Cari" Button
            _buildSearchBar(context, isDark),

            const SizedBox(height: 16),

            // 5. 8 Quick Menu Icons Grid (Squircles with exact layout from design)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _quickActions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.86,
                ),
                itemBuilder: (context, index) {
                  final item = _quickActions[index];
                  return _buildMenuItem(item, isDark);
                },
              ),
            ),

            const SizedBox(height: 16),

            // 6. Video Pembelajaran Terbaru (Cards with real thumbnails)
            _buildRecentVideosSection(isDark),

            const SizedBox(height: 16),

            // 7. Paket Belajar Unggulan
            _buildFeaturedPackagesSection(packageProvider, isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Floating KPM AI Deep Blue Circular Button with White Icon & Text
      floatingActionButton: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)], // Deep Blue
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.45),
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
                Icon(Icons.smart_toy_rounded, color: Colors.white, size: 23),
                SizedBox(height: 2),
                Text(
                  'KPM AI',
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
    );
  }

  Widget _buildModernHeader(BuildContext context, String initialChar, bool isLoggedIn, String? fullName, String? profilePhoto, int cartCount, bool isDark) {
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Profile Avatar & Name (or Masuk / Daftar button)
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
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isLoggedIn ? AppTheme.primaryBlue : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    backgroundImage: isLoggedIn ? avatarImg : null,
                    child: (isLoggedIn && avatarImg == null)
                        ? Text(
                            initialChar,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          )
                        : (isLoggedIn ? null : const Icon(Icons.person_outline_rounded, color: AppTheme.primaryBlue, size: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isLoggedIn) ...[
                          Text(
                            'Halo, ${fullName ?? "Siswa KPM"} 👋',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Mau belajar apa hari ini?',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                            ),
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Text(
                                'Masuk / Daftar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppTheme.primaryBlue),
                            ],
                          ),
                          Text(
                            'Klik untuk simpan progres & simulasi ujian',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Cart Button with badge
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.shopping_cart_outlined, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary, size: 22),
            ),
            tooltip: 'Keranjang Belajar',
          ),
          // Notification Button with unread indicator badge
          Consumer<NotificationService>(
            builder: (context, notifService, _) {
              final unreadCount = notifService.unreadCount;
              return IconButton(
                onPressed: () => Navigator.pushNamed(context, '/notification'),
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text('$unreadCount'),
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.notifications_outlined, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary, size: 22),
                ),
                tooltip: 'Notifikasi',
              );
            },
          ),
        ],
      ),
    );
  }

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
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background Image
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

                        // Translucent Gradient Overlay for optimal photo vibrancy
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.black.withValues(alpha: 0.15),
                                Colors.black.withValues(alpha: 0.82),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Top Badges
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
                              // Bottom Title & Subtitle
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
                    color: activeIndex == i ? AppTheme.primaryBlue : Colors.grey.withValues(alpha: 0.35),
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
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left info: PROGRES BELAJAR, Rata-rata, Latihan/Soal count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'PROGRES BELAJAR',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryBlue,
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
                    '$totalPractice Latihan • $correctAnswers Soal Benar',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Right: 3 Action icons (Latihan, Rapor, Beli)
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

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/search'),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCardColor : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppTheme.primaryBlue, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cari materi, paket belajar, atau video...',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Cari',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item, bool isDark) {
    final IconData icon = item['icon'] as IconData;
    final Color bgColor = item['bgColor'] as Color;
    final Color iconColor = item['iconColor'] as Color;
    final String title = item['title'] as String;
    final String route = item['route'] as String;
    final bool isProtected = item['protected'] as bool;

    return GestureDetector(
      onTap: () {
        if (isProtected) {
          AuthGuard.check(context, featureName: title, onAuthenticated: () => Navigator.pushNamed(context, route));
        } else {
          Navigator.pushNamed(context, route);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Squircle container matching design
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? bgColor.withValues(alpha: 0.18) : bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

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
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/video_list'),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
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
                    decoration: AppTheme.bentoBoxDecoration(context: context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Real Thumbnail Container with image & play overlay
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                          child: SizedBox(
                            height: 96,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (thumbUrl != null && thumbUrl.isNotEmpty)
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
                                // Dark subtle overlay for contrast
                                Container(
                                  color: Colors.black.withValues(alpha: 0.2),
                                ),
                                // Play icon badge
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
                                // Duration tag in bottom right
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
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/package_list'),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
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
              decoration: AppTheme.bentoBoxDecoration(context: context),
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
                          gradient: AppTheme.ruangguruGradient,
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
                                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${pkg.jenjang} ${pkg.kelas}',
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
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
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
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
                                color: isInCart ? AppTheme.accentGreen : AppTheme.primaryBlue,
                                size: 17,
                              ),
                              tooltip: 'Keranjang',
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
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
}
