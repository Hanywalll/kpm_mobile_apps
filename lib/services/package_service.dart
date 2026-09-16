import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/package_model.dart';

class PackageService {
  final ApiClient _apiClient;

  PackageService(this._apiClient);

  Future<List<PackageModel>> getPackages({String? gradeLevel, String? category}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.packages,
        queryParameters: {
          if (gradeLevel != null) 'grade_level': gradeLevel,
          if (category != null) 'category': category,
        },
      );
      final List data = response.data['data'] ?? [];
      return data.map((e) => PackageModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memuat daftar paket';
    }
  }

  Future<PackageModel> getPackageDetail(String id) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.packageDetail(id));
      return PackageModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memuat detail paket';
    }
  }

  Future<Map<String, dynamic>> createOrder(String packageId, String paymentMethod) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.createOrder,
        data: {'package_id': packageId, 'payment_method': paymentMethod},
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal membuat pesanan';
    }
  }

  Future<Map<String, dynamic>> activateEnrollKey(String code) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.activateEnrollKey,
        data: {'enroll_key': code},
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Aktivasi kode gagal';
    }
  }
}
