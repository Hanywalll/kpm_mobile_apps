import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/package_model.dart';
import '../models/order_model.dart';

class PackageService {
  final ApiClient _apiClient;

  static const String midtransServerKey = String.fromEnvironment('MIDTRANS_SERVER_KEY', defaultValue: '');
  static const String midtransClientKey = String.fromEnvironment('MIDTRANS_CLIENT_KEY', defaultValue: '');
  static const String midtransMerchantId = String.fromEnvironment('MIDTRANS_MERCHANT_ID', defaultValue: '');

  PackageService(this._apiClient);

  Future<List<PackageModel>> getPackages({
    String? kelas,
    String? jenjang,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.packages,
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (kelas != null && kelas.isNotEmpty) 'kelas': kelas,
          if (jenjang != null && jenjang.isNotEmpty) 'jenjang': jenjang,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      final List data = response.data['data'] ?? [];
      final list = data.map((e) => PackageModel.fromJson(e as Map<String, dynamic>)).toList();
      if (list.isNotEmpty) return list;
      return _getFilteredDemoPackages(jenjang: jenjang, search: search);
    } on DioException catch (_) {
      return _getFilteredDemoPackages(jenjang: jenjang, search: search);
    }
  }

  Future<PackageModel> getPackageDetail(String id) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.packageDetail(id));
      return PackageModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (_) {
      final demoList = _getDemoPackages();
      return demoList.firstWhere(
        (p) => p.id == id,
        orElse: () => demoList.first,
      );
    }
  }

  Future<Map<String, dynamic>?> createMidtransSnapTransaction({
    required String orderId,
    required double grossAmount,
    String? customerName,
    String? customerEmail,
  }) async {
    try {
      final auth = base64Encode(utf8.encode('$midtransServerKey:'));
      final snapDio = Dio(BaseOptions(
        baseUrl: 'https://app.sandbox.midtrans.com/snap/v1',
        headers: {
          'Authorization': 'Basic $auth',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      final response = await snapDio.post(
        '/transactions',
        data: {
          'transaction_details': {
            'order_id': orderId,
            'gross_amount': grossAmount.toInt(),
          },
          'customer_details': {
            'first_name': customerName ?? 'Siswa KPM Academy',
            'email': customerEmail ?? 'siswa@kpmacademy.com',
          },
          'expiry': {
            'duration': 60,
            'unit': 'minutes',
          },
        },
      );

      return response.data as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkMidtransStatus(String orderNumber) async {
    try {
      final auth = base64Encode(utf8.encode('$midtransServerKey:'));
      final statusDio = Dio(BaseOptions(
        baseUrl: 'https://api.sandbox.midtrans.com/v2',
        headers: {
          'Authorization': 'Basic $auth',
          'Accept': 'application/json',
        },
      ));

      final response = await statusDio.get('/$orderNumber/status');
      return response.data as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<OrderModel> createOrder(
    String packageId, {
    double? totalPrice,
    bool isCustomAmount = false,
  }) async {
    final orderNum = 'ORD-KPM-${DateTime.now().millisecondsSinceEpoch}';
    final amount = totalPrice ?? 150000;

    // 1. Generate real Midtrans Snap transaction
    final snapData = await createMidtransSnapTransaction(
      orderId: orderNum,
      grossAmount: amount,
    );

    final snapUrl = snapData?['redirect_url'] as String? ?? 'https://app.sandbox.midtrans.com/snap/v2/vtweb/demo';
    final snapToken = snapData?['token'] as String? ?? 'snap_demo_token';

    final matchedPackage = _getDemoPackages().firstWhere(
      (p) => p.id == packageId,
      orElse: () => PackageModel(
        id: packageId,
        title: 'Paket Belajar KPM',
        description: 'Akses Lengkap Materi KPM',
        price: amount,
      ),
    );

    OrderModel finalOrder;
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.orders,
        data: {
          'package_id': packageId,
          if (totalPrice != null) 'total_price': totalPrice,
          'is_custom_amount': isCustomAmount,
        },
      );
      final model = OrderModel.fromJson(response.data['data'] ?? response.data);
      final pUrl = model.paymentUrl;
      finalOrder = OrderModel(
        id: model.id.isNotEmpty ? model.id : 'ord_${DateTime.now().millisecondsSinceEpoch}',
        userId: model.userId.isNotEmpty ? model.userId : 'kpm_student_1',
        packageId: model.packageId ?? packageId,
        package: model.package ?? matchedPackage,
        orderNumber: model.orderNumber.isNotEmpty ? model.orderNumber : orderNum,
        totalPrice: model.totalPrice > 0 ? model.totalPrice : amount,
        paymentStatus: model.paymentStatus,
        paymentUrl: (pUrl != null && pUrl.isNotEmpty && !pUrl.contains('demo')) ? pUrl : snapUrl,
        paymentReference: model.paymentReference ?? snapToken,
        createdAt: model.createdAt ?? DateTime.now().toIso8601String(),
      );
    } catch (_) {
      finalOrder = OrderModel(
        id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'kpm_student_1',
        packageId: packageId,
        package: matchedPackage,
        orderNumber: orderNum,
        totalPrice: amount,
        paymentStatus: 'pending',
        paymentUrl: snapUrl,
        paymentReference: snapToken,
        createdAt: DateTime.now().toIso8601String(),
      );
    }

    // Save to local cache so it appears immediately in history
    await _loadOrdersFromPrefs();
    if (_cachedOrders.isEmpty) {
      _cachedOrders = _getDemoOrders();
    }
    _cachedOrders.removeWhere((o) => o.id == finalOrder.id || o.orderNumber == finalOrder.orderNumber);
    _cachedOrders.insert(0, finalOrder);
    await _saveOrdersToPrefs();

    return finalOrder;
  }

  static List<OrderModel> _cachedOrders = [];
  static const String _ordersPrefKey = 'kpm_cached_orders_v2';

  static Future<void> _loadOrdersFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_ordersPrefKey);
      if (raw != null && raw.isNotEmpty) {
        final List decoded = jsonDecode(raw);
        _cachedOrders = decoded.map((e) => OrderModel.fromJson(e)).toList();
      }
    } catch (_) {}
  }

  static Future<void> _saveOrdersToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listMap = _cachedOrders.map((e) => e.toJson()).toList();
      await prefs.setString(_ordersPrefKey, jsonEncode(listMap));
    } catch (_) {}
  }

  Future<List<OrderModel>> getUserOrders() async {
    return getOrderHistory();
  }

  Future<List<OrderModel>> getOrderHistory() async {
    await _loadOrdersFromPrefs();
    if (_cachedOrders.isEmpty) {
      _cachedOrders = _getDemoOrders();
      await _saveOrdersToPrefs();
    }

    try {
      final response = await _apiClient.dio.get(ApiEndpoints.myOrders);
      final List data = response.data['data'] ?? [];
      final list = data.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
      if (list.isNotEmpty) {
        for (final remote in list) {
          final idx = _cachedOrders.indexWhere((c) => c.id == remote.id || c.orderNumber == remote.orderNumber);
          if (idx >= 0) {
            _cachedOrders[idx] = remote;
          } else {
            _cachedOrders.add(remote);
          }
        }
        await _saveOrdersToPrefs();
      }
    } catch (_) {}

    return List<OrderModel>.from(_cachedOrders);
  }

  List<OrderModel> _getDemoOrders() {
    final packages = _getDemoPackages();
    return [
      OrderModel(
        id: 'ord_demo_1',
        userId: 'kpm_student_1',
        packageId: packages[0].id,
        package: packages[0],
        orderNumber: 'INV/2026/KPM/98214',
        totalPrice: packages[0].effectivePrice,
        paymentStatus: 'paid',
        paymentType: 'GoPay / QRIS',
        createdAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      ),
      OrderModel(
        id: 'ord_demo_2',
        userId: 'kpm_student_1',
        packageId: packages[1].id,
        package: packages[1],
        orderNumber: 'INV/2026/KPM/98340',
        totalPrice: packages[1].effectivePrice,
        paymentStatus: 'pending',
        paymentType: 'BCA Virtual Account',
        paymentUrl: 'https://app.sandbox.midtrans.com/snap/v2/vtweb/demo',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
      ),
    ];
  }

  Future<OrderModel> getOrderDetail(String id) async {
    await _loadOrdersFromPrefs();
    final local = _cachedOrders.firstWhere(
      (o) => o.id == id || o.orderNumber == id,
      orElse: () => _getDemoOrders().first,
    );
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.orderDetail(id));
      return OrderModel.fromJson(response.data['data'] ?? response.data);
    } catch (_) {
      return local;
    }
  }

  Future<void> simulatePayOrder(String orderId) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.simulatePayOrder(orderId));
    } catch (_) {}

    await _loadOrdersFromPrefs();
    if (_cachedOrders.isEmpty) {
      _cachedOrders = _getDemoOrders();
    }

    bool matched = false;
    for (int i = 0; i < _cachedOrders.length; i++) {
      final o = _cachedOrders[i];
      if (o.id == orderId ||
          o.orderNumber == orderId ||
          orderId.contains(o.id) ||
          (orderId == 'ord_demo_2' && o.id == 'ord_demo_2')) {
        _cachedOrders[i] = o.copyWith(
          paymentStatus: 'paid',
          paymentType: 'Midtrans Sandbox (Lunas)',
          paymentTime: DateTime.now().toIso8601String(),
        );
        matched = true;
      }
    }

    if (!matched) {
      // If not specifically matched by ID, update the first pending order or ord_demo_2
      for (int i = 0; i < _cachedOrders.length; i++) {
        if (_cachedOrders[i].isPending) {
          _cachedOrders[i] = _cachedOrders[i].copyWith(
            paymentStatus: 'paid',
            paymentType: 'Midtrans Sandbox (Lunas)',
            paymentTime: DateTime.now().toIso8601String(),
          );
          break;
        }
      }
    }

    await _saveOrdersToPrefs();
  }

  List<PackageModel> _getFilteredDemoPackages({String? jenjang, String? search}) {
    List<PackageModel> list = _getDemoPackages();
    if (jenjang != null && jenjang != 'Semua' && jenjang.isNotEmpty) {
      list = list.where((p) => p.jenjang.toLowerCase() == jenjang.toLowerCase()).toList();
    }
    if (search != null && search.isNotEmpty) {
      list = list.where((p) => p.title.toLowerCase().contains(search.toLowerCase())).toList();
    }
    return list;
  }

  List<PackageModel> _getDemoPackages() {
    return [
      PackageModel(
        id: '550e8400-e29b-41d4-a716-446655440001',
        title: 'Paket Belajar & Latihan Matematika Nalaria Realistik (MNR)',
        description: 'Pembelajaran metode MNR khas KPM untuk melatih logika berpikir nalar, kartu konsep terpadu, dan bank soal latihan berkala.',
        kelas: 'SD & SMP',
        jenjang: 'SD',
        price: 150000,
        discountPrice: 99000,
        isDiscountActive: true,
        membershipDurationDays: 90,
        timeLimitMinutes: 60,
      ),
      PackageModel(
        id: '550e8400-e29b-41d4-a716-446655440002',
        title: 'Paket Intensif Olimpiade Sains & MIPA Nasional',
        description: 'Pembinaan komprehensif kompetisi sains dan olimpiade matematika berstandar nasional bersama tim Master Coach KPM.',
        kelas: 'SMP & SMA',
        jenjang: 'SMP',
        price: 250000,
        discountPrice: 175000,
        isDiscountActive: true,
        membershipDurationDays: 120,
        timeLimitMinutes: 90,
      ),
      PackageModel(
        id: '550e8400-e29b-41d4-a716-446655440003',
        title: 'Paket Pendalaman Aljabar, Geometri & Penalaran Logika',
        description: 'Kupas tuntas seluruh tipe soal aljabar lanjutan, geometri spasial, dan penalaran induktif-deduktif matematika.',
        kelas: 'SMP & SMA',
        jenjang: 'SMA',
        price: 199000,
        discountPrice: 129000,
        isDiscountActive: true,
        membershipDurationDays: 90,
        timeLimitMinutes: 60,
      ),
      PackageModel(
        id: '550e8400-e29b-41d4-a716-446655440004',
        title: 'Paket Masterclass Sains Terpadu & Eksperimen MIPA SMA',
        description: 'Pemahaman konsep mendalam Fisika, Kimia, dan Biologi terintegrasi dengan latihan soal berbasis penalaran analitis.',
        kelas: 'SMA',
        jenjang: 'SMA',
        price: 299000,
        discountPrice: 199000,
        isDiscountActive: true,
        membershipDurationDays: 180,
        timeLimitMinutes: 100,
      ),
      PackageModel(
        id: '550e8400-e29b-41d4-a716-446655440005',
        title: 'Paket Full Access Ekosistem KPM Academy 1 Tahun',
        description: 'Akses tanpa batas ke seluruh materi, modul PDF, rekaman video, simulasi ujian online, dan konsultasi AI Tutor selama 1 tahun penuh.',
        kelas: 'Semua Jenjang',
        jenjang: 'Olimpiade',
        price: 499000,
        discountPrice: 349000,
        isDiscountActive: true,
        membershipDurationDays: 365,
        timeLimitMinutes: 120,
      ),
    ];
  }
}
