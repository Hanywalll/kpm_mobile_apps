import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatter.dart';
import '../../models/banner_model.dart';
import '../../models/live_class_model.dart';
import '../../models/module_model.dart';
import '../../models/package_model.dart';
import '../../models/video_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/package_provider.dart';
import '../../services/admin_service.dart';
import '../../services/dashboard_service.dart';
import '../../services/package_service.dart';
import '../../services/video_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AdminDashboardStats _stats = AdminDashboardStats();
  bool _isLoadingStats = true;

  List<BannerModel> _banners = [];
  List<LiveClassModel> _liveClasses = [];
  List<ModuleModel> _modules = [];
  List<VideoModel> _videos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadAllAdminData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAllAdminData() async {
    setState(() => _isLoadingStats = true);
    final adminService = Provider.of<AdminService>(context, listen: false);
    final dashboardService = Provider.of<DashboardService>(context, listen: false);
    final videoService = Provider.of<VideoService>(context, listen: false);

    final stats = await adminService.getDashboardStats();
    final banners = await dashboardService.getBanners();
    final liveClasses = await dashboardService.getLiveClasses();
    final modules = await dashboardService.getModules();
    final videos = await videoService.getVideos();

    if (mounted) {
      setState(() {
        _stats = stats;
        _banners = banners;
        _liveClasses = liveClasses;
        _modules = modules;
        _videos = videos;
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!authProvider.isAdmin) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
        appBar: AppBar(
          leading: AppTheme.backButton(context),
          title: const Text('Akses Ditolak'),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.admin_panel_settings_outlined, size: 72, color: Colors.redAccent),
                ),
                const SizedBox(height: 24),
                Text(
                  'Akses Khusus Administrator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  authProvider.isAuthenticated
                      ? 'Akun Anda (${authProvider.user?.email}) terdaftar sebagai Siswa dan tidak memiliki izin Administrator untuk mengakses halaman CMS ini.'
                      : 'Halaman ini dilindungi dan hanya dapat diakses setelah melakukan login dengan akun Administrator KPM Academy.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                if (!authProvider.isAuthenticated)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.login_rounded, size: 20),
                    label: const Text('Login Akun Admin', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Kembali ke Beranda'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
      appBar: AppBar(
        leading: AppTheme.backButton(context),
        title: const Text('Admin CMS & Control Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadAllAdminData,
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: AppTheme.compactTabBar(
            controller: _tabController,
            tabs: const [
              'Banner Slider',
              'Live Class',
              'Paket Belajar',
              'Video Materi',
              'Modul PDF',
              'Kupon Promo',
            ],
            context: context,
          ),
        ),
      ),
      body: _isLoadingStats
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 1. Metric Overview Header Cards (Compact Bento)
                _buildOverviewMetrics(isDark),

                // 2. Tab Views for Each Component
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBannerManager(isDark),
                      _buildLiveClassManager(isDark),
                      _buildPackageManager(isDark),
                      _buildVideoManager(isDark),
                      _buildModuleManager(isDark),
                      _buildVoucherManager(isDark),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // --- 1. Top Metrics Bento Grid ---
  Widget _buildOverviewMetrics(bool isDark) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCardColor : Colors.white,
        border: Border(
          bottom: BorderSide(color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor),
        ),
      ),
      child: Row(
        children: [
          _metricTile('Total Siswa', '${_stats.totalUsers}', Icons.people_rounded, AppTheme.primaryBlue, isDark),
          const SizedBox(width: 8),
          _metricTile('Pesanan', '${_stats.totalOrders}', Icons.receipt_long_rounded, const Color(0xFF0284C7), isDark),
          const SizedBox(width: 8),
          _metricTile('Pendapatan', currencyFormatter.format(_stats.totalRevenue), Icons.account_balance_wallet_rounded, const Color(0xFF059669), isDark),
        ],
      ),
    );
  }

  Widget _metricTile(String label, String val, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              val,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. Banner Slider Manager ---
  Widget _buildBannerManager(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildActionHeader('Banner Promo di Beranda', 'Tambah Banner Baru', Icons.add_photo_alternate_rounded, () {
          _showAddBannerModal(isDark);
        }),
        const SizedBox(height: 12),
        ..._banners.map((b) => _buildBannerCard(b, isDark)),
      ],
    );
  }

  Widget _buildBannerCard(BannerModel banner, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.bentoBoxDecoration(context: context),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: banner.imageUrl,
              width: 80,
              height: 52,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200, width: 80, height: 52),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(banner.tag, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                ),
                const SizedBox(height: 3),
                Text(banner.title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                Text('Rute: ${banner.route ?? "-"}', style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
            onPressed: () {
              setState(() => _banners.removeWhere((item) => item.id == banner.id));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Banner berhasil dihapus')));
            },
          ),
        ],
      ),
    );
  }

  // --- 3. Live Class Manager ---
  Widget _buildLiveClassManager(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildActionHeader('Jadwal Live Class & Streaming', 'Buat Live Class Baru', Icons.video_call_rounded, () {
          _showAddLiveClassModal(isDark);
        }),
        const SizedBox(height: 12),
        ..._liveClasses.map((lc) => _buildLiveClassCard(lc, isDark)),
      ],
    );
  }

  Widget _buildLiveClassCard(LiveClassModel lc, bool isDark) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.bentoBoxDecoration(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: lc.isLiveNow ? Colors.red.withValues(alpha: 0.1) : AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  lc.isLiveNow ? '● SEDANG LIVE' : 'TERJADWAL',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: lc.isLiveNow ? Colors.red : AppTheme.primaryBlue),
                ),
              ),
              Switch(
                value: lc.isLiveNow,
                activeColor: Colors.red,
                onChanged: (val) {
                  setState(() {
                    final idx = _liveClasses.indexWhere((item) => item.id == lc.id);
                    if (idx >= 0) {
                      _liveClasses[idx] = LiveClassModel(
                        id: lc.id,
                        title: lc.title,
                        instructor: lc.instructor,
                        subject: lc.subject,
                        jenjang: lc.jenjang,
                        scheduledAt: lc.scheduledAt,
                        durationMinutes: lc.durationMinutes,
                        zoomUrl: lc.zoomUrl,
                        status: val ? 'live' : 'upcoming',
                        bannerUrl: lc.bannerUrl,
                      );
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Status Live Class "${lc.title}" diubah menjadi ${val ? "LIVE" : "Upcoming"}')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(lc.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text('Tutor: ${lc.instructor} • ${lc.subject}', style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary)),
          Text('Waktu: ${dateFormat.format(lc.scheduledAt)} WIB', style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted)),
        ],
      ),
    );
  }

  // --- 4. Package Manager ---
  Widget _buildPackageManager(bool isDark) {
    final packageProvider = Provider.of<PackageProvider>(context);
    final packages = packageProvider.packages;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildActionHeader('Katalog Paket Belajar & Tryout', 'Tambah Paket Baru', Icons.add_box_rounded, () {
          _showAddPackageModal(isDark);
        }),
        const SizedBox(height: 12),
        ...packages.map((pkg) => _buildPackageCard(pkg, isDark)),
      ],
    );
  }

  Widget _buildPackageCard(PackageModel pkg, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.bentoBoxDecoration(context: context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.school_rounded, color: AppTheme.primaryBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pkg.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(
                  '${Formatter.formatRupiah(pkg.effectivePrice)} • ${pkg.jenjang} (${pkg.membershipDurationDays} Hari)',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. Video Manager ---
  Widget _buildVideoManager(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildActionHeader('Katalog Video Materi HD', 'Upload Video Baru', Icons.video_library_rounded, () {
          _showAddVideoModal(isDark);
        }),
        const SizedBox(height: 12),
        ..._videos.map((vid) => _buildVideoCard(vid, isDark)),
      ],
    );
  }

  Widget _buildVideoCard(VideoModel vid, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.bentoBoxDecoration(context: context),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: vid.thumbnail ?? 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=600&auto=format&fit=crop&q=80',
              width: 80,
              height: 52,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200, width: 80, height: 52),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vid.title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(vid.isFree ? 'GRATIS' : Formatter.formatRupiah(vid.price), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. Module Manager ---
  Widget _buildModuleManager(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildActionHeader('Modul Bacaan & Materi PDF', 'Tambah Modul PDF', Icons.picture_as_pdf_rounded, () {
          _showAddModuleModal(isDark);
        }),
        const SizedBox(height: 12),
        ..._modules.map((m) => _buildModuleCard(m, isDark)),
      ],
    );
  }

  Widget _buildModuleCard(ModuleModel m, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.bentoBoxDecoration(context: context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text('${m.tag} • ${m.totalChapters} Bab • ${m.fileSize}', style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 7. Voucher Manager ---
  Widget _buildVoucherManager(bool isDark) {
    final List<Map<String, dynamic>> vouchers = [
      {'code': 'KPMJUARA2026', 'title': 'Diskon 25% Persiapan Ujian', 'discount': '25%', 'usage': '142/500'},
      {'code': 'MNRINDONESIA', 'title': 'Potongan Rp 50.000 Belajar', 'discount': 'Rp 50rb', 'usage': '89/300'},
      {'code': 'MIPABERSAMA', 'title': 'Cashback 15% Ujian Online', 'discount': '15%', 'usage': '210/1000'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildActionHeader('Kupon Voucher & Diskon Promo', 'Buat Kupon Baru', Icons.confirmation_number_rounded, () {
          _showAddVoucherModal(isDark);
        }),
        const SizedBox(height: 12),
        ...vouchers.map((v) => _buildVoucherCard(v, isDark)),
      ],
    );
  }

  Widget _buildVoucherCard(Map<String, dynamic> v, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.bentoBoxDecoration(context: context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(v['code'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF8B5CF6))),
              ),
              const SizedBox(height: 4),
              Text(v['title'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary)),
              Text('Terpakai: ${v['usage']}', style: TextStyle(fontSize: 10, color: isDark ? AppTheme.darkTextMuted : AppTheme.textMuted)),
            ],
          ),
          Text(v['discount'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue)),
        ],
      ),
    );
  }

  // Helper Header with Add Button
  Widget _buildActionHeader(String title, String btnText, IconData icon, VoidCallback onAdd) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: onAdd,
          icon: Icon(icon, size: 16),
          label: Text(btnText, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // --- Modals for Adding Components ---
  void _showAddBannerModal(bool isDark) {
    final titleCtrl = TextEditingController();
    final tagCtrl = TextEditingController(text: 'PROMO');
    final imageCtrl = TextEditingController(text: 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=900&auto=format&fit=crop&q=80');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambah Banner Promo Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: tagCtrl, decoration: const InputDecoration(labelText: 'Tag Banner (Contoh: UJIAN ONLINE)')),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul Banner')),
            TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'URL Gambar Banner (HD)')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    setState(() {
                      _banners.insert(
                        0,
                        BannerModel(
                          id: 'banner_${DateTime.now().millisecondsSinceEpoch}',
                          tag: tagCtrl.text.trim(),
                          subTag: 'Promo Baru',
                          title: titleCtrl.text.trim(),
                          subtitle: 'Penawaran spesial siswa KPM Academy',
                          imageUrl: imageCtrl.text.trim(),
                          route: '/package_list',
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Banner baru berhasil diterbitkan di Beranda! 🚀')));
                  }
                },
                child: const Text('Terbitkan Banner', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLiveClassModal(bool isDark) {
    final titleCtrl = TextEditingController();
    final tutorCtrl = TextEditingController(text: 'Dr. Ir. R. Ridwan Hasan Saputra, M.Si.');
    final subjectCtrl = TextEditingController(text: 'Matematika MNR');
    final zoomCtrl = TextEditingController(text: 'https://zoom.us/j/kpmacademy');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Buat Jadwal Live Class Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul Topik Live Class')),
            TextField(controller: tutorCtrl, decoration: const InputDecoration(labelText: 'Nama Tutor / Pembina')),
            TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Mata Pelajaran')),
            TextField(controller: zoomCtrl, decoration: const InputDecoration(labelText: 'Tautan Zoom / Streaming')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    setState(() {
                      _liveClasses.insert(
                        0,
                        LiveClassModel(
                          id: 'live_${DateTime.now().millisecondsSinceEpoch}',
                          title: titleCtrl.text.trim(),
                          instructor: tutorCtrl.text.trim(),
                          subject: subjectCtrl.text.trim(),
                          jenjang: 'SD, SMP, & SMA',
                          scheduledAt: DateTime.now().add(const Duration(hours: 2)),
                          durationMinutes: 90,
                          zoomUrl: zoomCtrl.text.trim(),
                          status: 'upcoming',
                          bannerUrl: 'https://images.unsplash.com/photo-1588072432836-e10032774350?w=800&auto=format&fit=crop&q=80',
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jadwal Live Class baru berhasil dibuat! 🎥')));
                  }
                },
                child: const Text('Buat Jadwal Live Class', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPackageModal(bool isDark) {
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '199000');
    final discountCtrl = TextEditingController(text: '129000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tambah Paket Belajar Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Nama Paket')),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga Normal (Rp)')),
            TextField(controller: discountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga Diskon (Rp)')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paket belajar baru berhasil ditambahkan ke katalog! 📚')));
                  }
                },
                child: const Text('Simpan Paket', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVideoModal(bool isDark) {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController(text: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tambah Video Materi Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul Video Materi')),
            TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'URL Video MP4 / Streaming')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    setState(() {
                      _videos.insert(
                        0,
                        VideoModel(
                          id: 'vid_${DateTime.now().millisecondsSinceEpoch}',
                          title: titleCtrl.text.trim(),
                          description: 'Video materi pembelajaran interaktif KPM Academy.',
                          thumbnail: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=600&auto=format&fit=crop&q=80',
                          videoUrl: urlCtrl.text.trim(),
                          price: 0,
                          accessDurationDays: 60,
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video pembelajaran baru berhasil diunggah! 🎬')));
                  }
                },
                child: const Text('Simpan Video', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddModuleModal(bool isDark) {
    final titleCtrl = TextEditingController();
    final tagCtrl = TextEditingController(text: 'Matematika');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tambah Modul PDF Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul Modul')),
            TextField(controller: tagCtrl, decoration: const InputDecoration(labelText: 'Mata Pelajaran / Tag')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty) {
                    setState(() {
                      _modules.insert(
                        0,
                        ModuleModel(
                          id: 'mod_${DateTime.now().millisecondsSinceEpoch}',
                          title: titleCtrl.text.trim(),
                          description: 'Modul konsep dan latihan soal mandiri.',
                          tag: tagCtrl.text.trim(),
                          totalChapters: 4,
                          fileUrl: 'https://kpmacademic.io/modules/sample.pdf',
                          fileSize: '3.0 MB',
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Modul PDF baru berhasil diterbitkan! 📑')));
                  }
                },
                child: const Text('Simpan Modul', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVoucherModal(bool isDark) {
    final codeCtrl = TextEditingController();
    final titleCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Buat Kupon Voucher Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Kode Voucher (Contoh: KPMHEMAT50)')),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Keterangan Promo')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                onPressed: () {
                  if (codeCtrl.text.isNotEmpty) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kupon voucher baru berhasil diaktifkan! 🎟️')));
                  }
                },
                child: const Text('Aktifkan Voucher', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
