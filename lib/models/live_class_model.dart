class LiveClassModel {
  final String id;
  final String title;
  final String instructor;
  final String subject;
  final String jenjang;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String zoomUrl;
  final String status; // 'upcoming', 'live', 'ended'
  final String? bannerUrl;

  LiveClassModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.subject,
    required this.jenjang,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.zoomUrl,
    required this.status,
    this.bannerUrl,
  });

  factory LiveClassModel.fromJson(Map<String, dynamic> json) {
    return LiveClassModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Live Class KPM',
      instructor: json['instructor']?.toString() ?? json['tutor']?.toString() ?? 'Master Tutor KPM',
      subject: json['subject']?.toString() ?? json['category']?.toString() ?? 'Matematika MNR',
      jenjang: json['jenjang']?.toString() ?? json['grade']?.toString() ?? 'Semua Jenjang',
      scheduledAt: DateTime.tryParse(json['scheduled_at']?.toString() ?? '') ?? DateTime.now().add(const Duration(hours: 2)),
      durationMinutes: int.tryParse(json['duration_minutes']?.toString() ?? '') ?? 90,
      zoomUrl: json['zoom_url']?.toString() ?? json['meeting_url']?.toString() ?? 'https://zoom.us',
      status: json['status']?.toString() ?? 'upcoming',
      bannerUrl: json['banner_url']?.toString(),
    );
  }

  bool get isLiveNow => status == 'live' || (DateTime.now().isAfter(scheduledAt) && DateTime.now().isBefore(scheduledAt.add(Duration(minutes: durationMinutes))));
}
