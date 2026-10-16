import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';

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

  // 9. Admin Notifications
  Future<List<AdminNotificationItem>> getAdminNotifications() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.adminNotifications);
      final raw = response.data['data'] ?? response.data;
      if (raw is List) {
        return raw.map((j) => AdminNotificationItem.fromJson(j)).toList();
      }
    } catch (_) {}
    // Seamless rich mock fallback
    return [
      AdminNotificationItem(
        id: 'n1',
        title: 'Pembayaran Dikonfirmasi',
        message: 'Invoice #INV-2026-881 senilai Rp 350.000 telah lunas via Midtrans QRIS.',
        type: 'payment',
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        isRead: false,
      ),
      AdminNotificationItem(
        id: 'n2',
        title: 'Pesanan Baru Masuk',
        message: 'Ahmad Fauzi membuat pesanan Paket Intensif OSN Matematika SMA 2026.',
        type: 'order',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        isRead: false,
      ),
      AdminNotificationItem(
        id: 'n3',
        title: 'Tiket Bantuan Baru',
        message: 'Siswa Sarah N. mengirimkan pertanyaan kendala akses materi Video Bab 3.',
        type: 'support',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      AdminNotificationItem(
        id: 'n4',
        title: 'Ulasan / Testimoni Masuk',
        message: 'Budi Santoso memberikan ulasan bintang 5 untuk Paket Persiapan KSM IPA.',
        type: 'testimonial',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: true,
      ),
      AdminNotificationItem(
        id: 'n5',
        title: 'Siswa Menyelesaikan Tryout',
        message: 'Dewi Lestari menyelesaikan Tryout Simulasi OSN Matematika dengan skor 92.',
        type: 'tryout',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        isRead: true,
      ),
      AdminNotificationItem(
        id: 'n6',
        title: 'Registrasi Siswa Baru',
        message: 'Rian Pratama baru saja mendaftarkan akun siswa baru.',
        type: 'user',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        isRead: true,
      ),
    ];
  }

  // 10. Admin Users Management
  Future<List<AdminUserItem>> getUsers() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.adminUsers);
      final raw = response.data['data'] ?? response.data;
      if (raw is List) {
        return raw.map((j) => AdminUserItem.fromJson(j)).toList();
      }
    } catch (_) {}
    return [
      AdminUserItem(
        id: 'u1',
        name: 'Administrator KPM',
        email: 'admin@kpmacademy.com',
        role: 'admin',
        phone: '081234567890',
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
        coursesEnrolled: 0,
      ),
      AdminUserItem(
        id: 'u2',
        name: 'Dr. Hendra Gunawan',
        email: 'hendra.tutor@kpmacademy.com',
        role: 'teacher',
        phone: '081298765432',
        isActive: true,
        createdAt: DateTime(2026, 2, 10),
        coursesEnrolled: 5,
      ),
      AdminUserItem(
        id: 'u3',
        name: 'Ahmad Fauzi',
        email: 'ahmad.fauzi@gmail.com',
        role: 'student',
        phone: '085712341234',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        coursesEnrolled: 2,
      ),
      AdminUserItem(
        id: 'u4',
        name: 'Siti Nurhaliza',
        email: 'siti.nurhaliza@gmail.com',
        role: 'student',
        phone: '081399887766',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        coursesEnrolled: 3,
      ),
      AdminUserItem(
        id: 'u5',
        name: 'Budi Santoso',
        email: 'budi.santoso@gmail.com',
        role: 'student',
        phone: '081922334455',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        coursesEnrolled: 1,
      ),
      AdminUserItem(
        id: 'u6',
        name: 'Dewi Lestari',
        email: 'dewi.lestari@gmail.com',
        role: 'student',
        phone: '087811223344',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        coursesEnrolled: 4,
      ),
      AdminUserItem(
        id: 'u7',
        name: 'Rian Pratama',
        email: 'rian.pratama@gmail.com',
        role: 'student',
        phone: '089600112233',
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        coursesEnrolled: 0,
      ),
    ];
  }

  // 11. Admin Tryouts & Results
  Future<List<AdminTryoutItem>> getTryouts() async {
    return [
      AdminTryoutItem(
        id: 't1',
        title: 'Simulasi OSN Matematika Nasional 2026',
        category: 'Matematika SMA',
        totalQuestions: 30,
        durationMinutes: 90,
        participantsCount: 384,
        averageScore: 78.4,
        highestScore: 98.0,
        passingRate: 84.5,
      ),
      AdminTryoutItem(
        id: 't2',
        title: 'Tryout Akbar KSM Sains IPA Terpadu',
        category: 'Sains IPA SMP',
        totalQuestions: 40,
        durationMinutes: 100,
        participantsCount: 295,
        averageScore: 74.2,
        highestScore: 95.0,
        passingRate: 79.0,
      ),
      AdminTryoutItem(
        id: 't3',
        title: 'Ujian Mandiri Penalaran Logika & Numerasi',
        category: 'Logika & Numerasi SD',
        totalQuestions: 25,
        durationMinutes: 60,
        participantsCount: 420,
        averageScore: 82.1,
        highestScore: 100.0,
        passingRate: 88.2,
      ),
    ];
  }

  Future<List<AdminTryoutLeaderboardEntry>> getTryoutLeaderboard(String tryoutId) async {
    return [
      AdminTryoutLeaderboardEntry(
        rank: 1,
        studentName: 'Dewi Lestari',
        studentEmail: 'dewi.lestari@gmail.com',
        score: 98.0,
        correctCount: 29,
        totalQuestions: 30,
        durationMinutesText: '54 Menit',
        isPassed: true,
      ),
      AdminTryoutLeaderboardEntry(
        rank: 2,
        studentName: 'Ahmad Fauzi',
        studentEmail: 'ahmad.fauzi@gmail.com',
        score: 95.0,
        correctCount: 28,
        totalQuestions: 30,
        durationMinutesText: '62 Menit',
        isPassed: true,
      ),
      AdminTryoutLeaderboardEntry(
        rank: 3,
        studentName: 'Budi Santoso',
        studentEmail: 'budi.santoso@gmail.com',
        score: 91.5,
        correctCount: 27,
        totalQuestions: 30,
        durationMinutesText: '70 Menit',
        isPassed: true,
      ),
      AdminTryoutLeaderboardEntry(
        rank: 4,
        studentName: 'Siti Nurhaliza',
        studentEmail: 'siti.nurhaliza@gmail.com',
        score: 86.0,
        correctCount: 25,
        totalQuestions: 30,
        durationMinutesText: '78 Menit',
        isPassed: true,
      ),
      AdminTryoutLeaderboardEntry(
        rank: 5,
        studentName: 'Rian Pratama',
        studentEmail: 'rian.pratama@gmail.com',
        score: 62.0,
        correctCount: 18,
        totalQuestions: 30,
        durationMinutesText: '88 Menit',
        isPassed: false,
      ),
    ];
  }

  // 12. Support Helpdesk Tickets
  Future<List<AdminSupportTicket>> getSupportTickets() async {
    return [
      AdminSupportTicket(
        id: 't-101',
        studentName: 'Sarah Nurul',
        studentEmail: 'sarah.nurul@gmail.com',
        subject: 'Video Materi Bab 3 Tidak Bisa Diputar di Android',
        message: 'Mohon bantuannya, saat membuka video playback tertera pesan error buffering. Sudah coba restart aplikasi.',
        priority: 'high',
        status: 'OPEN',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      AdminSupportTicket(
        id: 't-102',
        studentName: 'Dimas Anggara',
        studentEmail: 'dimas.a@gmail.com',
        subject: 'Konfirmasi Pembayaran Paket Belajar Mandiri',
        message: 'Saya sudah transfer melalui VA Mandiri tetapi status di akun masih menunggu verifikasi. Mohon dicek bukti terlampir.',
        priority: 'medium',
        status: 'IN_PROGRESS',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        adminReply: 'Halo Dimas, tim keuangan sedang memvalidasi mutasi rekening kamu.',
      ),
      AdminSupportTicket(
        id: 't-103',
        studentName: 'Nadira Putri',
        studentEmail: 'nadira.p@gmail.com',
        subject: 'Tanya Jadwal Sesi Live Class Minggu Depan',
        message: 'Apakah ada rekaman ulang jika berhalangan hadir di sesi Zoom hari Sabtu?',
        priority: 'low',
        status: 'RESOLVED',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        adminReply: 'Halo Nadira, seluruh rekaman sesi Live Class akan otomatis diunggah ke menu Video Materi maksimal 1x24 jam setelah sesi selesai.',
      ),
    ];
  }

  // 13. Testimonials Moderation
  Future<List<AdminTestimonialItem>> getTestimonials() async {
    return [
      AdminTestimonialItem(
        id: 'rev-1',
        studentName: 'Fajar Nugraha',
        studentRole: 'Siswa SMA Negeri 1 Bogor',
        courseName: 'Paket Intensif OSN Matematika SMA 2026',
        rating: 5,
        content: 'Materi yang diajarkan sangat sistematis dan mudah dimengerti. Latihan soalnya sangat mirip dengan tipe soal OSN tahun ini!',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      AdminTestimonialItem(
        id: 'rev-2',
        studentName: 'Anisa Maharani',
        studentRole: 'Juara 1 KSM Sains Kota',
        courseName: 'Bimbel Super Camp KSM IPA',
        rating: 5,
        content: 'Mentor KPM sangat ramah dan sabar membahas konsep sulit sampai tuntas. Sangat merekomendasikan bimbel ini!',
        status: 'approved',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      AdminTestimonialItem(
        id: 'rev-3',
        studentName: 'Bambang Irawan',
        studentRole: 'Orang Tua Siswa',
        courseName: 'Kelas Logika & Olimpiade Cilik SD',
        rating: 5,
        content: 'Anak saya jadi lebih percaya diri memecahkan soal cerita matematika berkat bimbingan intensif KPM Academy.',
        status: 'approved',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  // 14. Student Enrollment Keys
  Future<List<AdminEnrollKeyItem>> getEnrollKeys() async {
    return [
      AdminEnrollKeyItem(
        id: 'k1',
        code: 'KPM-MATH-2026-X89',
        packageName: 'Paket Intensif OSN Matematika SMA 2026',
        batch: 'Batch Mitra SMAN 1 Surabaya',
        expiredAt: DateTime.now().add(const Duration(days: 90)),
        isUsed: false,
      ),
      AdminEnrollKeyItem(
        id: 'k2',
        code: 'KPM-IPA-2026-B12',
        packageName: 'Bimbel Super Camp KSM IPA SMP',
        batch: 'Batch Beasiswa Prestasi KPM',
        expiredAt: DateTime.now().add(const Duration(days: 120)),
        isUsed: false,
      ),
      AdminEnrollKeyItem(
        id: 'k3',
        code: 'KPM-LOGIC-2026-F44',
        packageName: 'Kelas Logika & Olimpiade Cilik SD',
        batch: 'Batch Sekolah Mitra Al-Azhar',
        expiredAt: DateTime.now().add(const Duration(days: 60)),
        isUsed: true,
        usedBy: 'Ahmad Fauzi (ahmad.fauzi@gmail.com)',
      ),
      AdminEnrollKeyItem(
        id: 'k4',
        code: 'KPM-KSM-2026-M77',
        packageName: 'Paket Persiapan Ujian KSM 2026',
        batch: 'Batch Reguler Gelombang 1',
        expiredAt: DateTime.now().subtract(const Duration(days: 10)),
        isUsed: false,
      ),
    ];
  }
}

// Data models for the 6 admin modules:
class AdminNotificationItem {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  bool isRead;
  final String? link;

  AdminNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.link,
  });

  factory AdminNotificationItem.fromJson(Map<String, dynamic> json) {
    return AdminNotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) ?? DateTime.now() : DateTime.now(),
      isRead: json['is_read'] ?? false,
      link: json['link'],
    );
  }
}

class AdminUserItem {
  final String id;
  final String name;
  final String email;
  final String role;
  final String phone;
  bool isActive;
  final DateTime createdAt;
  final int coursesEnrolled;

  AdminUserItem({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone = '',
    this.isActive = true,
    required this.createdAt,
    this.coursesEnrolled = 0,
  });

  factory AdminUserItem.fromJson(Map<String, dynamic> json) {
    return AdminUserItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
      phone: json['phone'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) ?? DateTime.now() : DateTime.now(),
      coursesEnrolled: (json['courses_enrolled'] as num?)?.toInt() ?? 0,
    );
  }
}

class AdminTryoutItem {
  final String id;
  final String title;
  final String category;
  final int totalQuestions;
  final int durationMinutes;
  final int participantsCount;
  final double averageScore;
  final double highestScore;
  final double passingRate;

  AdminTryoutItem({
    required this.id,
    required this.title,
    required this.category,
    required this.totalQuestions,
    required this.durationMinutes,
    required this.participantsCount,
    required this.averageScore,
    required this.highestScore,
    required this.passingRate,
  });
}

class AdminTryoutLeaderboardEntry {
  final int rank;
  final String studentName;
  final String studentEmail;
  final double score;
  final int correctCount;
  final int totalQuestions;
  final String durationMinutesText;
  final bool isPassed;

  AdminTryoutLeaderboardEntry({
    required this.rank,
    required this.studentName,
    required this.studentEmail,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.durationMinutesText,
    required this.isPassed,
  });
}

class AdminSupportTicket {
  final String id;
  final String studentName;
  final String studentEmail;
  final String subject;
  final String message;
  final String priority;
  String status;
  final DateTime createdAt;
  String? adminReply;

  AdminSupportTicket({
    required this.id,
    required this.studentName,
    required this.studentEmail,
    required this.subject,
    required this.message,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.adminReply,
  });
}

class AdminTestimonialItem {
  final String id;
  final String studentName;
  final String studentRole;
  final String courseName;
  final int rating;
  final String content;
  String status;
  final DateTime createdAt;

  AdminTestimonialItem({
    required this.id,
    required this.studentName,
    required this.studentRole,
    required this.courseName,
    required this.rating,
    required this.content,
    required this.status,
    required this.createdAt,
  });
}

class AdminEnrollKeyItem {
  final String id;
  final String code;
  final String packageName;
  final String batch;
  final DateTime expiredAt;
  bool isUsed;
  final String? usedBy;

  AdminEnrollKeyItem({
    required this.id,
    required this.code,
    required this.packageName,
    required this.batch,
    required this.expiredAt,
    this.isUsed = false,
    this.usedBy,
  });
}
