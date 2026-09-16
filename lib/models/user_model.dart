class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String whatsapp;
  final String gradeLevel;
  final String? targetSchool;
  final String? avatarUrl;
  final String? membershipStatus;
  final String? membershipExpiry;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.whatsapp,
    required this.gradeLevel,
    this.targetSchool,
    this.avatarUrl,
    this.membershipStatus,
    this.membershipExpiry,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      gradeLevel: json['grade_level'] ?? json['gradeLevel'] ?? 'SMA 12',
      targetSchool: json['target_school'] ?? json['targetSchool'],
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      membershipStatus: json['membership_status'] ?? json['membershipStatus'],
      membershipExpiry: json['membership_expiry'] ?? json['membershipExpiry'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'whatsapp': whatsapp,
      'grade_level': gradeLevel,
      'target_school': targetSchool,
      'avatar_url': avatarUrl,
      'membership_status': membershipStatus,
      'membership_expiry': membershipExpiry,
    };
  }
}
