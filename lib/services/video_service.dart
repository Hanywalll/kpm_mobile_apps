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

  static List<VideoModel> getDemoVideosList() {
    return [
      VideoModel(
        id: 'vid_1',
        title: 'Master Trik Cepat Logaritma & Eksponen',
        description: 'Pembahasan lengkap trik 10 detik menyelesaikan soal logaritma UTBK bersama Master Tutor KPM.',
        thumbnail: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=600&auto=format&fit=crop&q=80',
        videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
        price: 0,
        accessDurationDays: 30,
      ),
      VideoModel(
        id: 'vid_2',
        title: 'Rahasia Menjawab TPS Penalaran Logika 100%',
        description: 'Strategi membaca cepat teks panjang dan menarik kesimpulan silogisme tanpa terjebak distraktor.',
        thumbnail: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=600&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        price: 49000,
        accessDurationDays: 60,
      ),
      VideoModel(
        id: 'vid_3',
        title: 'Bedah Tuntas Kinematika Gerak & Vektor',
        description: 'Konsep dasar hingga soal level olimpiade Fisika SMA & UTBK Saintek bersama pembina olimpiade.',
        thumbnail: 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=600&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        price: 0,
        accessDurationDays: 30,
      ),
      VideoModel(
        id: 'vid_4',
        title: 'Trik Matematika Nalaria Realistik (MNR) SD-SMP',
        description: 'Metode berpikir nalar kreatif menyelesaikan soal cerita matematika tanpa hafalan rumus.',
        thumbnail: 'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=600&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        price: 0,
        accessDurationDays: 90,
      ),
      VideoModel(
        id: 'vid_5',
        title: 'Konsep Dasar Stoikiometri & Hitungan Mol Kimia',
        description: 'Panduan step-by-step menyetarakan reaksi dan konversi mol zat kimia secara akurat.',
        thumbnail: 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=600&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        price: 35000,
        accessDurationDays: 60,
      ),
    ];
  }
}
