class LeaderboardEntry {
  final int rank;
  final String userId;
  final String name;
  final String? studentClass;
  final String? schoolName;
  final String? avatar;
  final double avgScore;
  final int totalPractice;
  final int totalCorrect;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    this.studentClass,
    this.schoolName,
    this.avatar,
    required this.avgScore,
    required this.totalPractice,
    required this.totalCorrect,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      userId: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['student_name']?.toString() ?? 'Siswa KPM',
      studentClass: json['student_class']?.toString() ?? json['class']?.toString() ?? 'SMA',
      schoolName: json['school_name']?.toString() ?? 'KPM Academy',
      avatar: json['avatar']?.toString() ?? json['profile_photo']?.toString(),
      avgScore: (json['avg_score'] as num?)?.toDouble() ?? (json['score'] as num?)?.toDouble() ?? 0.0,
      totalPractice: (json['total_practice'] as num?)?.toInt() ?? 0,
      totalCorrect: (json['total_correct'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'user_id': userId,
      'name': name,
      'student_class': studentClass,
      'school_name': schoolName,
      'avatar': avatar,
      'avg_score': avgScore,
      'total_practice': totalPractice,
      'total_correct': totalCorrect,
    };
  }
}
