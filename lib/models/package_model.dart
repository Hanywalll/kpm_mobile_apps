class PackageModel {
  final String id;
  final String name;
  final String category;
  final String gradeLevel;
  final double price;
  final double? originalPrice;
  final String description;
  final String? thumbnailUrl;
  final double rating;
  final int totalModules;
  final int totalQuestions;
  final bool hasVideoAccess;
  final int activeDays;

  PackageModel({
    required this.id,
    required this.name,
    required this.category,
    required this.gradeLevel,
    required this.price,
    this.originalPrice,
    required this.description,
    this.thumbnailUrl,
    this.rating = 5.0,
    required this.totalModules,
    required this.totalQuestions,
    required this.hasVideoAccess,
    required this.activeDays,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'Reguler',
      gradeLevel: json['grade_level'] ?? json['gradeLevel'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? json['thumbnailUrl'],
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalModules: json['total_modules'] ?? json['totalModules'] ?? 0,
      totalQuestions: json['total_questions'] ?? json['totalQuestions'] ?? 0,
      hasVideoAccess: json['has_video_access'] ?? json['hasVideoAccess'] ?? false,
      activeDays: json['active_days'] ?? json['activeDays'] ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'grade_level': gradeLevel,
      'price': price,
      'original_price': originalPrice,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'rating': rating,
      'total_modules': totalModules,
      'total_questions': totalQuestions,
      'has_video_access': hasVideoAccess,
      'active_days': activeDays,
    };
  }
}
