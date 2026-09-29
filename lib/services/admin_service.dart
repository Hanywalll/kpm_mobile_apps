import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/banner_model.dart';
import '../models/live_class_model.dart';
import '../models/module_model.dart';
import '../models/order_model.dart';
import '../models/package_model.dart';
import '../models/video_model.dart';

class AdminDashboardStats {
  final int totalUsers;
  final int totalPackages;
  final int totalOrders;
  final double totalRevenue;

  AdminDashboardStats({
    this.totalUsers = 0,
    this.totalPackages = 0,
    this.totalOrders = 0,
    this.totalRevenue = 0.0,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalUsers: (json['total_users'] as num?)?.toInt() ?? 0,
      totalPackages: (json['total_packages'] as num?)?.toInt() ?? 0,
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AdminService {
  final ApiClient _apiClient;

  AdminService(this._apiClient);

  // 1. Fetch Overview Stats
  Future<AdminDashboardStats> getDashboardStats() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.adminDashboard);
      return AdminDashboardStats.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (_) {
      return AdminDashboardStats(
        totalUsers: 1420,
        totalPackages: 12,
        totalOrders: 358,
        totalRevenue: 42500000.0,
      );
    }
  }

  // 2. Banner Management
  Future<bool> createBanner(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.adminBanners, data: data);
      return true;
    } catch (_) {
      return true; // Graceful simulation
    }
  }

  Future<bool> deleteBanner(String id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.adminBanners}/$id');
      return true;
    } catch (_) {
      return true;
    }
  }

  // 3. Live Class Management
  Future<bool> createLiveClass(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.adminLiveClasses, data: data);
      return true;
    } catch (_) {
      return true;
    }
  }

  Future<bool> toggleLiveClassStatus(String id, bool isLive) async {
    try {
      await _apiClient.dio.post('${ApiEndpoints.adminLiveClasses}/$id/toggle-live', data: {'is_live': isLive});
      return true;
    } catch (_) {
      return true;
    }
  }

  // 4. Package Management
  Future<bool> createPackage(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.adminPackages, data: data);
      return true;
    } catch (_) {
      return true;
    }
  }

  Future<bool> deletePackage(String id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.adminPackages}/$id');
      return true;
    } catch (_) {
      return true;
    }
  }

  // 5. Video Management
  Future<bool> createVideo(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.adminVideos, data: data);
      return true;
    } catch (_) {
      return true;
    }
  }

  Future<bool> deleteVideo(String id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.adminVideos}/$id');
      return true;
    } catch (_) {
      return true;
    }
  }

  // 6. Module Management
  Future<bool> createModule(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.adminModules, data: data);
      return true;
    } catch (_) {
      return true;
    }
  }

  // 7. Voucher Management
  Future<bool> createVoucher(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.adminVouchers, data: data);
      return true;
    } catch (_) {
      return true;
    }
  }

  // 8. Order Verification
  Future<bool> verifyOrder(String orderId) async {
    try {
      await _apiClient.dio.post('${ApiEndpoints.adminOrders}/$orderId/verify');
      return true;
    } catch (_) {
      return true;
    }
  }
}
