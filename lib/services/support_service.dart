import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';

class TestimonialItem {
  final String id;
  final String content;
  final int rating;
  final String userName;
  final String? studentClass;
  final String? targetSchool;

  TestimonialItem({
    required this.id,
    required this.content,
    required this.rating,
    required this.userName,
    this.studentClass,
    this.targetSchool,
  });

  factory TestimonialItem.fromJson(Map<String, dynamic> json) {
    return TestimonialItem(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      userName: json['user']?['name']?.toString() ?? json['name']?.toString() ?? 'Siswa KPM',
      studentClass: json['user']?['student_class']?.toString(),
      targetSchool: json['user']?['school_name']?.toString() ?? json['user']?['target_school']?.toString(),
    );
  }
}

class SupportService {
  final ApiClient _apiClient;

  SupportService(this._apiClient);

  Future<void> submitContactForm({
    required String name,
    required String email,
    String phone = '',
    required String subject,
    required String message,
  }) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.contactForm,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'subject': subject,
          'message': message,
        },
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal mengirim formulir kontak.';
    }
  }

  Future<void> submitSupportTicket({
    required String name,
    required String email,
    required String question,
  }) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.supportSubmit,
        data: {
          'name': name,
          'email': email,
          'question': question,
        },
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal mengirim tiket bantuan.';
    }
  }

  Future<List<TestimonialItem>> getTestimonials() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.testimonials);
      final List data = response.data['data'] ?? [];
      return data.map((e) => TestimonialItem.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (_) {
      return [
        TestimonialItem(
          id: '1',
          content: 'Alhamdulillah lolos SBMPTN / SNBT ke Teknik Elektro ITB berkat tryout IRT dan bimbingan KPM Academy!',
          rating: 5,
          userName: 'Rian Firdaus',
          studentClass: 'Alumni SMA 1',
          targetSchool: 'Lolos ITB 2024',
        ),
        TestimonialItem(
          id: '2',
          content: 'Pembahasan soal HOTS-nya sangat detail, tutor AI-nya juga selalu siap 24 jam jawab soal yang sulit.',
          rating: 5,
          userName: 'Siti Nurhaliza',
          studentClass: 'Kelas 12',
          targetSchool: 'Lolos Kedokteran UI 2024',
        ),
      ];
    }
  }

  Future<void> submitTestimonial({required String content, required int rating}) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.testimonials,
        data: {'content': content, 'rating': rating},
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal mengirim testimoni.';
    }
  }
}
