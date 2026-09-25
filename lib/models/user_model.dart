class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? studentName;
  final String? studentClass;
  final String? studentMajor;
  final String? schoolName;
  final String? profilePhoto;
  final String? address;
  final String? gender;
  final String? religion;
  final String role;
  final bool isVerified;
  final bool isActive;
  final String? lastLoginAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.studentName,
    this.studentClass,
    this.studentMajor,
    this.schoolName,
    this.profilePhoto,
    this.address,
    this.gender,
    this.religion,
    this.role = 'user',
    this.isVerified = true,
    this.isActive = true,
    this.lastLoginAt,
  });

  // Display Name convenience getter
  String get fullName => (studentName != null && studentName!.trim().isNotEmpty)
      ? studentName!
      : (name.isNotEmpty ? name : 'Siswa KPM');

  // School display convenience getter
  String get targetSchool => schoolName ?? 'Asal Sekolah / Target Belajar';

  // Grade/Class display convenience getter
  String get gradeLevel => studentClass ?? (studentMajor != null ? '$studentClass $studentMajor' : 'Kelas Siswa');

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['whatsapp']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? json['studentName']?.toString(),
      studentClass: json['student_class']?.toString() ?? json['grade_level']?.toString() ?? json['studentClass']?.toString(),
      studentMajor: json['student_major']?.toString() ?? json['studentMajor']?.toString(),
      schoolName: json['school_name']?.toString() ?? json['target_school']?.toString() ?? json['schoolName']?.toString(),
      profilePhoto: json['profile_photo']?.toString() ?? json['avatar_url']?.toString() ?? json['profilePhoto']?.toString(),
      address: json['address']?.toString(),
      gender: json['gender']?.toString(),
      religion: json['religion']?.toString(),
      role: json['role']?.toString() ?? 'user',
      isVerified: json['is_verified'] == true || json['isVerified'] == true,
      isActive: json['is_active'] != false && json['isActive'] != false,
      lastLoginAt: json['last_login_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'student_name': studentName,
      'student_class': studentClass,
      'student_major': studentMajor,
      'school_name': schoolName,
      'profile_photo': profilePhoto,
      'address': address,
      'gender': gender,
      'religion': religion,
      'role': role,
      'is_verified': isVerified,
      'is_active': isActive,
      'last_login_at': lastLoginAt,
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? studentName,
    String? studentClass,
    String? studentMajor,
    String? schoolName,
    String? profilePhoto,
    String? address,
    String? gender,
    String? religion,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      studentName: studentName ?? this.studentName,
      studentClass: studentClass ?? this.studentClass,
      studentMajor: studentMajor ?? this.studentMajor,
      schoolName: schoolName ?? this.schoolName,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      religion: religion ?? this.religion,
      role: role,
      isVerified: isVerified,
      isActive: isActive,
      lastLoginAt: lastLoginAt,
    );
  }
}
