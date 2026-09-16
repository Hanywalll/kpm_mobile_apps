class VideoModel {
  final String id;
  final String title;
  final String subject;
  final String videoUrl;
  final String? thumbnailUrl;
  final String duration;
  final String tutorName;

  VideoModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.duration,
    required this.tutorName,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      videoUrl: json['video_url'] ?? json['videoUrl'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'],
      duration: json['duration'] ?? '00:00',
      tutorName: json['tutor_name'] ?? json['tutorName'] ?? 'Tutor',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'duration': duration,
      'tutor_name': tutorName,
    };
  }
}
