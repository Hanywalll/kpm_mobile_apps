import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/video_model.dart';

class VideoService {
  final ApiClient _apiClient;

  VideoService(this._apiClient);

  Future<List<VideoModel>> getVideos({String? subject}) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.videos);
      final List data = response.data['data'] ?? [];
      if (data.isNotEmpty) {
        return data.map((e) => VideoModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      return _getDemoVideos();
    } on DioException catch (_) {
      return _getDemoVideos();
    }
  }

  Future<VideoModel> getVideoDetail(String id) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.videoDetail(id));
      return VideoModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (_) {
      final list = _getDemoVideos();
      return list.firstWhere((v) => v.id == id, orElse: () => list.first);
    }
  }

  Future<Map<String, dynamic>> createVideoOrder(String id, {double? totalPrice}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.videoOrder(id),
        data: {'total_price': totalPrice ?? 0.0},
      );
      return response.data['data'] ?? response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memesan video.';
    }
  }

  Future<void> simulateVideoPay(String videoId, String orderId) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.simulateVideoPay(videoId, orderId));
    } catch (_) {}
  }

  List<VideoModel> _getDemoVideos() => getDemoVideosList();

  static List<VideoModel> getVideosForPackage(dynamic packageOrId, List<VideoModel> source) {
    String pkgId = '';
    String jenjang = '';
    String title = '';

    if (packageOrId is String) {
      pkgId = packageOrId;
    } else if (packageOrId != null) {
      try {
        pkgId = (packageOrId.id as String?) ?? '';
        jenjang = (packageOrId.jenjang as String?) ?? '';
        title = (packageOrId.title as String?) ?? '';
      } catch (_) {}
    }

    // 1. Direct packageId match
    if (pkgId.isNotEmpty) {
      final matched = source.where((v) => v.packageId == pkgId).toList();
      if (matched.isNotEmpty) return matched;
    }

    // 2. Jenjang and topic match
    final j = jenjang.toLowerCase();
    final t = title.toLowerCase();

    final filtered = source.where((v) {
      final vt = v.title.toLowerCase();
      final vd = v.description.toLowerCase();

      if (j == 'sd' || pkgId.contains('sd') || t.contains('sd') || t.contains('mnr')) {
        return v.packageId?.contains('sd') == true ||
            vt.contains('sd') ||
            vt.contains('mnr') ||
            vd.contains('sd') ||
            vd.contains('nalaria') ||
            vd.contains('pecahan') ||
            vd.contains('berhitung');
      } else if (j == 'smp' || pkgId.contains('smp') || t.contains('smp')) {
        return v.packageId?.contains('smp') == true ||
            vt.contains('smp') ||
            vt.contains('aljabar') ||
            vt.contains('pythagoras') ||
            vt.contains('geometri') ||
            vd.contains('smp');
      } else if (j == 'sma' || pkgId.contains('sma') || t.contains('sma') || t.contains('utbk')) {
        return v.packageId?.contains('sma') == true ||
            vt.contains('utbk') ||
            vt.contains('tps') ||
            vt.contains('sma') ||
            vt.contains('logaritma') ||
            vt.contains('kimia') ||
            vt.contains('fisika') ||
            vt.contains('saintek') ||
            vd.contains('utbk') ||
            vd.contains('sma');
      }
      return true;
    }).toList();

    return filtered.isNotEmpty ? filtered : source.take(3).toList();
  }

  static List<VideoModel> getDemoVideosList() {
    return [
      // === MATERI PAKET SD (Matematika Nalaria Realistik & Sains SD) ===
      VideoModel(
        id: 'vid_sd_1',
        packageId: 'pkg-sd-01',
        title: 'Trik Penalaran Nalaria & Pola Bilangan SD',
        description: 'Metode berpikir nalar kreatif menyelesaikan soal cerita pola bilangan dan deret matematika dasar SD.',
        thumbnail: 'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=600&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        price: 0,
        accessDurationDays: 90,
      ),
      VideoModel(
        id: 'vid_sd_2',
        packageId: 'pkg-sd-01',
        title: 'Operasi Hitung Cepat & Logika Aritmatika SD',
        description: 'Trik penjumlahan, pengurangan beruntun, dan perkalian kreatif metode MNR KPM.',
        thumbnail: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=600&auto=format&fit=crop&q=80',
        videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
        price: 0,
        accessDurationDays: 90,
      ),
      VideoModel(
        id: 'vid_sd_3',
        packageId: 'pkg-sd-02',
        title: 'Mastering Pecahan & Perbandingan Nilai SD',
        description: 'Visualisasi pecahan senilai, persen, dan desimal dengan pendekatan grafis penalaran realistik.',
        thumbnail: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=600&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        price: 0,
        accessDurationDays: 90,
      ),
      VideoModel(
        id: 'vid_sd_4',
        packageId: 'pkg-sd-03',
        title: 'Bedah Tipe Soal OSN Matematika SD & Tips Medali',
        description: 'Pembahasan mendalam soal-soal eksplorasi tingkat kota dan provinsi bersama Master Pembina OSN.',
        thumbnail: 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=600&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        price: 0,
        accessDurationDays: 120,
      ),
      VideoModel(
        id: 'vid_sd_5',
        packageId: 'pkg-sd-04',
        title: 'Sains Terapan SD: Gaya, Gerak & Ekosistem Alam',
        description: 'Eksperimen virtual interaktif dan studi kasus fenomena sains di kehidupan sehari-hari.',
        thumbnail: 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=600&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        price: 0,
        accessDurationDays: 90,
      ),

      // === MATERI PAKET SMP (Aljabar, Geometri & IPA SMP) ===
      VideoModel(
        id: 'vid_smp_1',
        packageId: 'pkg-smp-01',
        title: 'Aljabar Cepat: Faktorisasi & SPLDV SMP',
        description: 'Sistematisasi pemfaktoran aljabar kuadrat dan substitusi kilat sistem persamaan linear.',
        thumbnail: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=600&auto=format&fit=crop&q=80',
        videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
        price: 0,
        accessDurationDays: 90,
      ),
      VideoModel(
        id: 'vid_smp_2',
        packageId: 'pkg-smp-02',
        title: 'Geometri Ruang & Tripel Pythagoras SMP',
        description: 'Trik menghitung luas permukaan, volume bangun gabungan, dan segitiga istimewa.',
        thumbnail: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=600&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        price: 0,
        accessDurationDays: 90,
      ),
      VideoModel(
        id: 'vid_smp_3',
        packageId: 'pkg-smp-03',
        title: 'Olimpiade IPA Terpadu: Gerak Lurus & Tekanan Zat SMP',
        description: 'Konsep GLB/GLBB, hukum pascal, fluida statis, dan soal analisis olimpiade sains SMP.',
        thumbnail: 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=600&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        price: 0,
        accessDurationDays: 120,
      ),

      // === MATERI PAKET SMA (UTBK TPS & Saintek SMA) ===
      VideoModel(
        id: 'vid_sma_1',
        packageId: 'pkg-sma-01',
        title: 'Master Trik Cepat Logaritma & Eksponen UTBK',
        description: 'Pembahasan lengkap trik 10 detik menyelesaikan soal logaritma UTBK bersama Master Tutor KPM.',
        thumbnail: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=600&auto=format&fit=crop&q=80',
        videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
        price: 0,
        accessDurationDays: 180,
      ),
      VideoModel(
        id: 'vid_sma_2',
        packageId: 'pkg-sma-01',
        title: 'Rahasia Menjawab TPS Penalaran Logika 100%',
        description: 'Strategi membaca cepat teks panjang dan menarik kesimpulan silogisme tanpa terjebak distraktor.',
        thumbnail: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=600&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        price: 0,
        accessDurationDays: 180,
      ),
      VideoModel(
        id: 'vid_sma_3',
        packageId: 'pkg-sma-02',
        title: 'Bedah Tuntas Kinematika Gerak & Vektor Saintek',
        description: 'Konsep dasar hingga soal level olimpiade Fisika SMA & UTBK Saintek bersama pembina olimpiade.',
        thumbnail: 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=600&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        price: 0,
        accessDurationDays: 180,
      ),
      VideoModel(
        id: 'vid_sma_4',
        packageId: 'pkg-sma-03',
        title: 'Konsep Dasar Stoikiometri & Hitungan Mol Kimia',
        description: 'Panduan step-by-step menyetarakan reaksi dan konversi mol zat kimia secara akurat.',
        thumbnail: 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=600&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        price: 0,
        accessDurationDays: 180,
      ),
    ];
  }
}
