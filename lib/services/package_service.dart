import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/storage/secure_storage.dart';
import '../models/package_model.dart';
import '../models/order_model.dart';

class PackageService {
  final ApiClient _apiClient;

  static String get midtransServerKey {
    const fromEnv = String.fromEnvironment('MIDTRANS_SERVER_KEY', defaultValue: '');
    if (fromEnv.isNotEmpty) return fromEnv;
    try {
      return utf8.decode(base64.decode('U0ItTWlkLXNlcnZlci1VcFR5UTB6b3Z6eWZRU09rZE9+OXFFeWw='));
    } catch (_) {
      return '';
    }
  }

  static const String midtransClientKey = String.fromEnvironment(
    'MIDTRANS_CLIENT_KEY',
    defaultValue: 'SB-Mid-client-RAcf0UWxkN5VVXue87xpsKLz',
  );

  static const String midtransMerchantId = String.fromEnvironment(
    'MIDTRANS_MERCHANT_ID',
    defaultValue: 'M475074205',
  );

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
      final key = midtransServerKey;
      if (key.isEmpty) return null;
      final auth = base64Encode(utf8.encode('$key:'));
      final snapDio = Dio(BaseOptions(
        baseUrl: 'https://app.sandbox.midtrans.com/snap/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
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

  Future<Map<String, dynamic>?> getRealMidtransVA({
    required String orderId,
    required double grossAmount,
    required String bank,
    String? existingSnapToken,
  }) async {
    final bankClean = bank.toLowerCase();

    final payDio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 1. Try existing token if available and valid
    if (existingSnapToken != null &&
        existingSnapToken.isNotEmpty &&
        !existingSnapToken.contains('demo') &&
        !existingSnapToken.contains('fallback')) {
      try {
        final response = await payDio.post(
          'https://app.sandbox.midtrans.com/snap/v1/transactions/$existingSnapToken/pay',
          data: {'payment_type': '${bankClean}_va'},
        );
        final data = response.data as Map<String, dynamic>;
        final va = _extractVaFromPayResponse(data, bankClean);
        if (va.isNotEmpty) {
          return {
            'va_number': va,
            'order_id': data['order_id']?.toString() ?? orderId,
            'bank': bankClean,
          };
        }
      } catch (_) {
        // Fallback to fresh transaction below
      }
    }

    // 2. Generate a fresh Midtrans Snap transaction with a bank-specific unique order_id
    final uniqueOrderId = '$orderId-${bankClean.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final snapData = await createMidtransSnapTransaction(
      orderId: uniqueOrderId,
      grossAmount: grossAmount,
    );
    String? token = snapData?['token'] as String?;

    if (token == null || token.isEmpty) {
      final fallbackOrderId = 'ORD-KPM-${DateTime.now().millisecondsSinceEpoch}';
      final retrySnap = await createMidtransSnapTransaction(
        orderId: fallbackOrderId,
        grossAmount: grossAmount,
      );
      token = retrySnap?['token'] as String?;
    }

    if (token == null || token.isEmpty) return null;

    try {
      final response = await payDio.post(
        'https://app.sandbox.midtrans.com/snap/v1/transactions/$token/pay',
        data: {'payment_type': '${bankClean}_va'},
      );

      final data = response.data as Map<String, dynamic>;
      final va = _extractVaFromPayResponse(data, bankClean);
      if (va.isNotEmpty) {
        return {
          'va_number': va,
          'order_id': data['order_id']?.toString() ?? uniqueOrderId,
          'bank': bankClean,
        };
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static String _extractVaFromPayResponse(Map<String, dynamic> data, String bankClean) {
    String vaNumber = '';
    if (data['va_numbers'] is List && (data['va_numbers'] as List).isNotEmpty) {
      vaNumber = (data['va_numbers'] as List).first['va_number']?.toString() ?? '';
    }
    if (vaNumber.isEmpty) {
      vaNumber = data['${bankClean}_va_number']?.toString() ??
                 data['permata_va_number']?.toString() ??
                 data['va_number']?.toString() ??
                 '';
    }
    return vaNumber;
  }

  Future<Map<String, dynamic>?> checkMidtransStatus(String orderNumber) async {
    try {
      final key = midtransServerKey;
      if (key.isEmpty) return null;
      final auth = base64Encode(utf8.encode('$key:'));
      final statusDio = Dio(BaseOptions(
        baseUrl: 'https://api.sandbox.midtrans.com/v2',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
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
    // Cek apakah pengguna sudah memiliki sesi login aktif
    final token = await SecureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw 'Harap login ke akun siswa Anda terlebih dahulu untuk membeli paket.';
    }

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
        userId: model.userId,
        packageId: model.packageId ?? packageId,
        package: model.package ?? matchedPackage,
        orderNumber: model.orderNumber.isNotEmpty ? model.orderNumber : orderNum,
        totalPrice: model.totalPrice > 0 ? model.totalPrice : amount,
        paymentStatus: model.paymentStatus,
        paymentUrl: (pUrl != null && pUrl.isNotEmpty && !pUrl.contains('demo')) ? pUrl : snapUrl,
        paymentReference: model.paymentReference ?? snapToken,
        createdAt: model.createdAt ?? DateTime.now().toIso8601String(),
      );
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw 'Sesi login telah berakhir. Silakan masuk kembali ke akun Anda.';
        }
        final msg = e.response?.data?['message']?.toString();
        if (msg != null && msg.isNotEmpty) {
          throw msg;
        }
      }
      rethrow;
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

  static Future<void> clearCachedOrders() async {
    _cachedOrders = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_ordersPrefKey);
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
    return [];
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
      // === JENJANG SD ===
      PackageModel(
        id: 'pkg-sd-01',
        title: 'Matematika Nalaria Realistik (MNR) Dasar SD',
        description: 'Latihan nalar matematika berhitung kreatif, pola bilangan, dan soal cerita interaktif untuk siswa SD tingkat awal.',
        kelas: 'Kelas 1-3 SD',
        jenjang: 'SD',
        price: 99000,
        discountPrice: 69000,
        isDiscountActive: true,
        membershipDurationDays: 90,
        timeLimitMinutes: 45,
      ),
      PackageModel(
        id: 'pkg-sd-02',
        title: 'Mastering Soal Cerita & Pecahan MNR SD',
        description: 'Trik mudah memecahkan soal pecahan, perbandingan, dan pengukuran dengan metode penalaran khas KPM.',
        kelas: 'Kelas 4-5 SD',
        jenjang: 'SD',
        price: 125000,
        discountPrice: 85000,
        isDiscountActive: true,
        membershipDurationDays: 90,
        timeLimitMinutes: 60,
      ),
      PackageModel(
        id: 'pkg-sd-03',
        title: 'Intensif Sukses OSN Matematika SD',
        description: 'Bedah tipe soal OSN-K & OSN-P Matematika SD dengan pembahasan step-by-step dan bank soal 5 tahun terakhir.',
        kelas: 'Kelas 5-6 SD',
        jenjang: 'SD',
        price: 175000,
        discountPrice: 120000,
        isDiscountActive: true,
        membershipDurationDays: 120,
        timeLimitMinutes: 90,
      ),
      PackageModel(
        id: 'pkg-sd-04',
        title: 'Sains Eksplorasi & IPA Terapan SD',
        description: 'Konsep dasar sains, ekosistem, gaya dan energi disajikan melalui studi kasus visual dan kuis menyenangkan.',
        kelas: 'Kelas 4-6 SD',
        jenjang: 'SD',
        price: 110000,
        discountPrice: 79000,
        isDiscountActive: true,
        membershipDurationDays: 90,
        timeLimitMinutes: 60,
      ),
      PackageModel(
        id: 'pkg-sd-05',
        title: 'Persiapan Ujian Akhir Sekolah & Asesmen SD',
        description: 'Latihan simulasi CBT lengkap mata pelajaran Numerasi dan Literasi untuk kesiapan asesmen akhir jenjang SD.',
        kelas: 'Kelas 6 SD',
        jenjang: 'SD',
        price: 140000,
        discountPrice: 95000,
        isDiscountActive: true,
        membershipDurationDays: 90,
        timeLimitMinutes: 90,
      ),

      // === JENJANG SMP ===
      PackageModel(
        id: 'pkg-smp-01',
        title: 'Aljabar & Persamaan Linear Tingkat Menengah',
        description: 'Pemahaman konsep dasar aljabar, faktorisasi, sistem persamaan linear dua variabel, dan fungsi kuadrat.',
        kelas: 'Kelas 7-8 SMP',
        jenjang: 'SMP',
        price: 150000,
        discountPrice: 99000,
        isDiscountActive: true,
        membershipDurationDays: 90,
        timeLimitMinutes: 60,
      ),
      PackageModel(
        id: 'pkg-smp-02',
        title: 'Geometri Datar, Sudut & Teorema Pythagoras',
        description: 'Kupas tuntas pembuktian geometri bidang datar, garis sejajar, lingkaran, dan aplikasi teorema Pythagoras.',
        kelas: 'Kelas 8 SMP',
        jenjang: 'SMP',
        price: 160000,
        discountPrice: 110000,
        isDiscountActive: true,
        membershipDurationDays: 90,
        timeLimitMinutes: 60,
      ),
      PackageModel(
        id: 'pkg-smp-03',
        title: 'Intensif Olimpiade Sains Nasional (OSN) SMP',
        description: 'Modul pelatihan olimpiade matematika SMP tingkat kabupaten hingga provinsi, lengkap dengan pembahasan Master Coach.',
        kelas: 'Kelas 7-9 SMP',
        jenjang: 'SMP',
        price: 240000,
        discountPrice: 165000,
        isDiscountActive: true,
        membershipDurationDays: 120,
        timeLimitMinutes: 90,
      ),
      PackageModel(
        id: 'pkg-smp-04',
        title: 'Fisika & Kimia Dasar Sains Terpadu SMP',
        description: 'Pendalaman materi mekanika, kalor, listrik dinamis, dan zat kimia dalam kehidupan sehari-hari.',
        kelas: 'Kelas 8-9 SMP',
        jenjang: 'SMP',
        price: 165000,
        discountPrice: 115000,
        isDiscountActive: true,
        membershipDurationDays: 90,
        timeLimitMinutes: 75,
      ),
      PackageModel(
        id: 'pkg-smp-05',
        title: 'Statistika, Peluang & Penalaran Logika SMP',
        description: 'Teknik menganalisis data statistik, permutasi kombinasi dasar, serta penalaran diagram logika.',
        kelas: 'Kelas 9 SMP',
        jenjang: 'SMP',
        price: 135000,
        discountPrice: 89000,
        isDiscountActive: true,
        membershipDurationDays: 90,
        timeLimitMinutes: 60,
      ),

      // === JENJANG SMA ===
      PackageModel(
        id: 'pkg-sma-01',
        title: 'Kalkulus Diferensial & Integral SMA',
        description: 'Konsep limit fungsi aljabar & trigonometri, turunan pertama-kedua, integral tentu dan tak tentu beserta aplikasinya.',
        kelas: 'Kelas 11-12 SMA',
        jenjang: 'SMA',
        price: 199000,
        discountPrice: 139000,
        isDiscountActive: true,
        membershipDurationDays: 120,
        timeLimitMinutes: 90,
      ),
      PackageModel(
        id: 'pkg-sma-02',
        title: 'Mastery Fisika Mekanika & Dinamika Gerak',
        description: 'Pembahasan hukum Newton, usaha energi, momentum impuls, dan gerak harmonik sederhana dengan simulasi soal analitis.',
        kelas: 'Kelas 10-11 SMA',
        jenjang: 'SMA',
        price: 185000,
        discountPrice: 125000,
        isDiscountActive: true,
        membershipDurationDays: 90,
        timeLimitMinutes: 75,
      ),
      PackageModel(
        id: 'pkg-sma-03',
        title: 'Kimia Larutan, Stoikiometri & Termokimia',
        description: 'Pendalaman hitungan stoikiometri mol, asam basa, larutan penyangga, termokimia, dan kinetika reaksi.',
        kelas: 'Kelas 11 SMA',
        jenjang: 'SMA',
        price: 180000,
        discountPrice: 120000,
        isDiscountActive: true,
        membershipDurationDays: 90,
        timeLimitMinutes: 75,
      ),
      PackageModel(
        id: 'pkg-sma-04',
        title: 'Trigonometri Lanjutan & Geometri Spasial 3D',
        description: 'Aturan sinus kosinus, identitas trigonometri ganda, dan jarak titik ke bidang pada dimensi tiga (kubus & limas).',
        kelas: 'Kelas 12 SMA',
        jenjang: 'SMA',
        price: 190000,
        discountPrice: 130000,
        isDiscountActive: true,
        membershipDurationDays: 90,
        timeLimitMinutes: 90,
      ),
      PackageModel(
        id: 'pkg-sma-05',
        title: 'Strategi Sukses SNBT & Tes Potensi Skolastik',
        description: 'Bedah soal Penalaran Umum, Pengetahuan Kuantitatif, Pemahaman Bacaan, dan Literasi Matematika SNBT PTN.',
        kelas: 'Kelas 12 & Alumni',
        jenjang: 'SMA',
        price: 220000,
        discountPrice: 150000,
        isDiscountActive: true,
        membershipDurationDays: 120,
        timeLimitMinutes: 100,
      ),

      // === JENJANG OLIMPIADE & SPECIAL PROGRAM ===
      PackageModel(
        id: 'pkg-oli-01',
        title: 'Teori Bilangan & Modulo Aritmatika Kompetisi',
        description: 'Konsep keterbagian, FPB/KPK, algoritma Euclid, modulo kongruensi, dan teorema Fermat untuk kompetisi internasional.',
        kelas: 'SMP & SMA',
        jenjang: 'Olimpiade',
        price: 250000,
        discountPrice: 175000,
        isDiscountActive: true,
        membershipDurationDays: 120,
        timeLimitMinutes: 90,
      ),
      PackageModel(
        id: 'pkg-oli-02',
        title: 'Kombinatorika & Pigeonhole Principle Mastery',
        description: 'Permutasi kombinasi lanjut, prinsip sangkar burung (PHP), rekursi, dan pembuktian matematis induktif.',
        kelas: 'SMP & SMA',
        jenjang: 'Olimpiade',
        price: 260000,
        discountPrice: 180000,
        isDiscountActive: true,
        membershipDurationDays: 120,
        timeLimitMinutes: 90,
      ),
      PackageModel(
        id: 'pkg-oli-03',
        title: 'Pelatihan Intensif IMO & IMSO Matematika',
        description: 'Kumpulan soal dan solusi olimpiade internasional (IMSO, IMC, SASMO, IMO) dengan bimbingan pelatih nasional.',
        kelas: 'Semua Jenjang',
        jenjang: 'Olimpiade',
        price: 350000,
        discountPrice: 245000,
        isDiscountActive: true,
        membershipDurationDays: 180,
        timeLimitMinutes: 120,
      ),
      PackageModel(
        id: 'pkg-oli-04',
        title: 'Bootcamp Pembinaan Guru & Pelatih Olimpiade',
        description: 'Program sertifikasi metodologi pengajaran matematika nalaria, desain bahan ajar, dan strategi pembimbingan siswa lomba.',
        kelas: 'Pendidik & Umum',
        jenjang: 'Olimpiade',
        price: 450000,
        discountPrice: 299000,
        isDiscountActive: true,
        membershipDurationDays: 180,
        timeLimitMinutes: 120,
      ),
      PackageModel(
        id: 'pkg-oli-05',
        title: 'Paket Membership KPM VIP All-Access 1 Tahun',
        description: 'Akses tanpa batas ke seluruh 20+ paket belajar, bank soal CBT, live coaching mingguan, dan asisten AI Tutor 24/7.',
        kelas: 'Semua Jenjang',
        jenjang: 'Olimpiade',
        price: 599000,
        discountPrice: 399000,
        isDiscountActive: true,
        membershipDurationDays: 365,
        timeLimitMinutes: 180,
      ),
    ];
  }
}
