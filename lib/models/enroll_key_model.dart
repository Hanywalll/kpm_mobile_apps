class EnrollKeyModel {
  final String code;
  final String packageName;
  final int activeDays;
  final String? status;

  EnrollKeyModel({
    required this.code,
    required this.packageName,
    required this.activeDays,
    this.status,
  });

  factory EnrollKeyModel.fromJson(Map<String, dynamic> json) {
    return EnrollKeyModel(
      code: json['code'] ?? '',
      packageName: json['package_name'] ?? json['packageName'] ?? '',
      activeDays: json['active_days'] ?? json['activeDays'] ?? 0,
      status: json['status'],
    );
  }
}
