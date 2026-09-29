import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/tutor_booking_model.dart';

class TutorService {
  final ApiClient _apiClient;

  TutorService(this._apiClient);

  Future<List<TutorModel>> getTutors() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.tutors);
      final List data = response.data['data'] ?? [];
      final list = data.map((e) => TutorModel.fromJson(e as Map<String, dynamic>)).toList();
      if (list.isNotEmpty) return list;
      return _getDefaultTutors();
    } on DioException catch (_) {
      return _getDefaultTutors();
    }
  }

  Future<TutorBookingModel> bookTutorSchedule({
    required String tutorId,
    required String scheduledDate,
    required String scheduledTimeSlot,
    required String subject,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.bookTutorSchedule(tutorId),
        data: {
          'scheduled_date': scheduledDate,
          'scheduled_time_slot': scheduledTimeSlot,
          'subject': subject,
          'notes': notes ?? '',
        },
      );
      return TutorBookingModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw e.response?.data['message'];
      }
      return TutorBookingModel(
        id: 'book_${DateTime.now().millisecondsSinceEpoch}',
        tutorId: tutorId,
        tutorName: 'Master Tutor KPM',
        studentId: 'demo_user_1',
        studentName: 'Siswa KPM',
        scheduledDate: scheduledDate,
        scheduledTimeSlot: scheduledTimeSlot,
        subject: subject,
        status: 'confirmed',
        meetingUrl: 'https://zoom.us/j/kpm_tutor_private',
        notes: notes,
      );
    }
  }

  Future<List<TutorBookingModel>> getMyBookings() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.myTutorBookings);
      final List data = response.data['data'] ?? [];
      return data.map((e) => TutorBookingModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (_) {
      return [];
    }
  }

  List<TutorModel> _getDefaultTutors() {
    return [
      TutorModel(
        id: 'tut_1',
        name: 'Dr. Ir. R. Ridwan Hasan Saputra, M.Si.',
        role: 'Master Coach Matematika Nalaria (MNR)',
        experience: '25+ Thn Pengalaman',
        rating: 5.0,
        totalSessions: 3500,
        avatar: 'https://api.dicebear.com/7.x/adventurer/png?seed=Ridwan',
        pricePerSession: 150000,
        specialties: ['MNR', 'Olimpiade', 'Pelatihan Guru'],
        availableSlots: ['09:00 - 10:30', '13:30 - 15:00', '19:30 - 21:00'],
      ),
      TutorModel(
        id: 'tut_2',
        name: 'Budi Pratama, M.Sc.',
        role: 'Master Tutor Fisika & Sains Terapan',
        experience: '10+ Thn Pengalaman',
        rating: 4.9,
        totalSessions: 1420,
        avatar: 'https://api.dicebear.com/7.x/adventurer/png?seed=Budi',
        pricePerSession: 120000,
        specialties: ['Fisika SMA', 'Olimpiade Sains'],
        availableSlots: ['10:00 - 11:30', '16:00 - 17:30', '20:00 - 21:30'],
      ),
      TutorModel(
        id: 'tut_3',
        name: 'Siti Rahma, S.Si.',
        role: 'Spesialis Matematika SD & SMP',
        experience: '8+ Thn Pengalaman',
        rating: 4.9,
        totalSessions: 1150,
        avatar: 'https://api.dicebear.com/7.x/adventurer/png?seed=Siti',
        pricePerSession: 100000,
        specialties: ['Matematika SD', 'Logika Berhitung'],
        availableSlots: ['08:30 - 10:00', '14:00 - 15:30', '16:30 - 18:00'],
      ),
      TutorModel(
        id: 'tut_4',
        name: 'Ahmad Fauzi, M.Pd.',
        role: 'Tutor Kimia & Asesmen Sains',
        experience: '7+ Thn Pengalaman',
        rating: 4.8,
        totalSessions: 890,
        avatar: 'https://api.dicebear.com/7.x/adventurer/png?seed=Fauzi',
        pricePerSession: 100000,
        specialties: ['Kimia Terapan', 'Eksperimen MIPA'],
        availableSlots: ['11:00 - 12:30', '15:30 - 17:00', '18:30 - 20:00'],
      ),
    ];
  }
}
