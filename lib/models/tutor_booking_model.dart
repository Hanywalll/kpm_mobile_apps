class TutorModel {
  final String id;
  final String name;
  final String role;
  final String experience;
  final double rating;
  final int totalSessions;
  final String avatar;
  final double pricePerSession;
  final List<String> specialties;
  final List<String> availableSlots;

  TutorModel({
    required this.id,
    required this.name,
    required this.role,
    required this.experience,
    required this.rating,
    required this.totalSessions,
    required this.avatar,
    required this.pricePerSession,
    required this.specialties,
    required this.availableSlots,
  });

  factory TutorModel.fromJson(Map<String, dynamic> json) {
    return TutorModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Master Tutor KPM',
      role: json['role']?.toString() ?? 'Tutor Pembina Olimpiade',
      experience: json['experience']?.toString() ?? '5+ Tahun',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalSessions: (json['total_sessions'] as num?)?.toInt() ?? 100,
      avatar: json['avatar']?.toString() ?? 'https://api.dicebear.com/7.x/adventurer/png?seed=KPM',
      pricePerSession: (json['price_per_session'] as num?)?.toDouble() ?? 100000.0,
      specialties: (json['specialties'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      availableSlots: (json['available_slots'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class TutorBookingModel {
  final String id;
  final String tutorId;
  final String tutorName;
  final String studentId;
  final String studentName;
  final String scheduledDate;
  final String scheduledTimeSlot;
  final String subject;
  final String status;
  final String? meetingUrl;
  final String? notes;

  TutorBookingModel({
    required this.id,
    required this.tutorId,
    required this.tutorName,
    required this.studentId,
    required this.studentName,
    required this.scheduledDate,
    required this.scheduledTimeSlot,
    required this.subject,
    required this.status,
    this.meetingUrl,
    this.notes,
  });

  factory TutorBookingModel.fromJson(Map<String, dynamic> json) {
    return TutorBookingModel(
      id: json['id']?.toString() ?? '',
      tutorId: json['tutor_id']?.toString() ?? '',
      tutorName: json['tutor_name']?.toString() ?? 'Tutor KPM',
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? 'Siswa',
      scheduledDate: json['scheduled_date']?.toString() ?? '',
      scheduledTimeSlot: json['scheduled_time_slot']?.toString() ?? '',
      subject: json['subject']?.toString() ?? 'Matematika & Sains',
      status: json['status']?.toString() ?? 'pending',
      meetingUrl: json['meeting_url']?.toString(),
      notes: json['notes']?.toString(),
    );
  }
}
