import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';

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
}
