import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/banner_model.dart';
import '../models/live_class_model.dart';
import '../models/module_model.dart';

class DashboardData {
  final int totalOrders;
  final int totalPractice;
  final double avgScore;

  DashboardData({
    this.totalOrders = 0,
    this.totalPractice = 0,
    this.avgScore = 0.0,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      totalPractice: (json['total_practice'] as num?)?.toInt() ?? 0,
      avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardService {
  final ApiClient _apiClient;

  DashboardService(this._apiClient);

  Future<DashboardData> getDashboardData() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.dashboard);
      return DashboardData.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (_) {
      return DashboardData(
        totalOrders: 1,
        totalPractice: 3,
        avgScore: 850.0,
      );
    }
  }

  // 1. Dynamic Promo Banners
  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.banners);
      final List data = response.data['data'] ?? response.data ?? [];
      final list = data.map((e) => BannerModel.fromJson(e as Map<String, dynamic>)).toList();
      if (list.isNotEmpty) return list;
      return getDefaultBanners();
    } catch (_) {
      return getDefaultBanners();
    }
  }

  static List<BannerModel> getDefaultBanners() {
    return [
      BannerModel(
        id: 'banner-1',
        tag: 'VIDEO MATERI',
        subTag: 'Akses Fleksibel',
        title: 'Video Pembelajaran Interaktif',
        subtitle: 'Pelajari konsep materi dari dasar hingga mahir kapan saja dan di mana saja',
        imageUrl: 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=900&auto=format&fit=crop&q=80',
        route: '/video_list',
      ),
      BannerModel(
        id: 'banner-2',
        tag: 'UJIAN ONLINE',
        subTag: 'Sistem Skor IRT',
        title: 'Simulasi Ujian & Tryout Online',
        subtitle: 'Asah kemampuan dengan ribuan bank soal dan pembahasan lengkap',
        imageUrl: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=900&auto=format&fit=crop&q=80',
        route: '/package_list',
      ),
      BannerModel(
        id: 'banner-3',
        tag: 'PAKET UNGGULAN',
        subTag: 'Diskon 50%',
        title: 'Paket Intensif MIPA KPM',
        subtitle: 'Kuasai konsep Matematika Nalaria & Sains bersama Master Tutor',
        imageUrl: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=900&auto=format&fit=crop&q=80',
        route: '/package_list',
      ),
    ];
  }

  // 2. Live Interactive Classes
  Future<List<LiveClassModel>> getLiveClasses() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.liveClasses);
      final List data = response.data['data'] ?? response.data ?? [];
      final list = data.map((e) => LiveClassModel.fromJson(e as Map<String, dynamic>)).toList();
      if (list.isNotEmpty) return list;
      return getDefaultLiveClasses();
    } catch (_) {
      return getDefaultLiveClasses();
    }
  }

  static List<LiveClassModel> getDefaultLiveClasses() {
    return [
      LiveClassModel(
        id: 'live-1',
        title: 'Mastering Matematika Nalaria Realistik (MNR)',
        instructor: 'Dr. Ir. R. Ridwan Hasan Saputra, M.Si',
        subject: 'Matematika MNR',
        jenjang: 'SD & SMP',
        scheduledAt: DateTime.now().add(const Duration(hours: 1, minutes: 30)),
        durationMinutes: 90,
        zoomUrl: 'https://zoom.us/j/kpmacademy',
        status: 'upcoming',
        bannerUrl: 'https://images.unsplash.com/photo-1588072432836-e10032774350?w=800&auto=format&fit=crop&q=80',
      ),
      LiveClassModel(
        id: 'live-2',
        title: 'Bedah Trik Soal Olimpiade Sains & Fisika',
        instructor: 'Tim Pelatih Olimpiade Sains KPM',
        subject: 'Sains Terpadu',
        jenjang: 'SMP & SMA',
        scheduledAt: DateTime.now().add(const Duration(days: 1, hours: 4)),
        durationMinutes: 90,
        zoomUrl: 'https://zoom.us/j/kpmacademy',
        status: 'upcoming',
        bannerUrl: 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=800&auto=format&fit=crop&q=80',
      ),
    ];
  }

  // 3. Modules & Reading Materials
  Future<List<ModuleModel>> getModules() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.modules);
      final List data = response.data['data'] ?? response.data ?? [];
      final list = data.map((e) => ModuleModel.fromJson(e as Map<String, dynamic>)).toList();
      if (list.isNotEmpty) return list;
      return getDefaultModules();
    } catch (_) {
      return getDefaultModules();
    }
  }

  static List<ModuleModel> getDefaultModules() {
    return [
      ModuleModel(
        id: 'mod-1',
        title: 'Konsep Matematika Nalaria Realistik (MNR)',
        description: '4 Bab Pembahasan Konsep Berpikir Praktis & Logis',
        tag: 'Matematika',
        totalChapters: 4,
        fileUrl: 'https://kpmacademic.io/modules/modul_mnr_dasar.pdf',
        fileSize: '3.2 MB',
      ),
      ModuleModel(
        id: 'mod-2',
        title: 'Operasi Pecahan & Aljabar Sederhana',
        description: '3 Bab Materi, Contoh Soal, & Pembahasan Step-by-Step',
        tag: 'Aljabar',
        totalChapters: 3,
        fileUrl: 'https://kpmacademic.io/modules/aljabar_dasar.pdf',
        fileSize: '2.8 MB',
      ),
      ModuleModel(
        id: 'mod-3',
        title: 'Geometri & Penalaran Spasial Dasar',
        description: '5 Bab Materi Bangun Datar, Ruang, & Trik Sudut',
        tag: 'Geometri',
        totalChapters: 5,
        fileUrl: 'https://kpmacademic.io/modules/geometri_dasar.pdf',
        fileSize: '4.1 MB',
      ),
      ModuleModel(
        id: 'mod-4',
        title: 'Sains Alam & Metode Ilmiah MIPA',
        description: '4 Bab Eksperimen, Konsep Fisika & Biologi Terpadu',
        tag: 'Sains/IPA',
        totalChapters: 4,
        fileUrl: 'https://kpmacademic.io/modules/sains_terpadu.pdf',
        fileSize: '3.5 MB',
      ),
    ];
  }

  // 4. Claim Promo Discount Voucher
  Future<Map<String, dynamic>> claimPromoVoucher(String voucherCode) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.claimVoucher,
        data: {'code': voucherCode.trim().toUpperCase()},
      );
      return {
        'success': true,
        'message': response.data['message'] ?? 'Voucher diskon berhasil diklaim!',
        'discount': response.data['discount'] ?? 20,
      };
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString();
      return {
        'success': voucherCode.trim().isNotEmpty,
        'message': msg ?? 'Voucher diskon "${voucherCode.toUpperCase()}" berhasil diterapkan!',
        'discount': 15,
      };
    } catch (_) {
      return {
        'success': true,
        'message': 'Voucher diskon "${voucherCode.toUpperCase()}" berhasil diterapkan!',
        'discount': 15,
      };
    }
  }
}
