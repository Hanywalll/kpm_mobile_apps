import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/video_model.dart';

class VideoService {
  final ApiClient _apiClient;

  VideoService(this._apiClient);

  Future<List<VideoModel>> getVideos({String? subject}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.videos,
        queryParameters: {
          if (subject != null) 'subject': subject,
        },
      );
      final List data = response.data['data'] ?? [];
      return data.map((e) => VideoModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memuat katalog video';
    }
  }
}
