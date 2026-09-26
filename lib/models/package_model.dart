import 'dart:convert';

class PackageCardItem {
  final String id;
  final String title;
  final String? description;
  final int totalQuestions;
  final int durationMinutes;

  PackageCardItem({
    required this.id,
    required this.title,
    this.description,
    this.totalQuestions = 10,
    this.durationMinutes = 30,
  });

  factory PackageCardItem.fromJson(Map<String, dynamic> json) {
    return PackageCardItem(
      id: json['id']?.toString() ?? json['card_id']?.toString() ?? 'card_1',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Modul Latihan',
      description: json['description']?.toString(),
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 10,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 30,
    );
  }
}

class PackageModel {
  final String id;
  final String title;
  final String description;
  final String? thumbnail;
  final String kelas;
  final String jenjang;
  final double price;
  final double? discountPrice;
  final bool isDiscountActive;
  final bool isPayWhatYouWant;
  final double minPayAmount;
  final int membershipDurationDays;
  final String? cardsRaw;
  final String? questionsRaw;
  final bool hideExplanation;
  final int? timeLimitMinutes;
  final bool isActive;
  final double rating;

  PackageModel({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnail,
    this.kelas = 'XII',
    this.jenjang = 'SMA',
    required this.price,
    this.discountPrice,
    this.isDiscountActive = false,
    this.isPayWhatYouWant = false,
    this.minPayAmount = 0.0,
    this.membershipDurationDays = 30,
    this.cardsRaw,
    this.questionsRaw,
    this.hideExplanation = false,
    this.timeLimitMinutes,
    this.isActive = true,
    this.rating = 4.9,
  });

  // UI convenience aliases
  String get name => title;
  String? get thumbnailUrl => thumbnail;
  int get activeDays => membershipDurationDays;
  bool get hasVideoAccess => true;

  double get effectivePrice {
    if (isDiscountActive && discountPrice != null && discountPrice! > 0) {
      return discountPrice!;
    }
    return price;
  }

  bool get hasDiscount =>
      isDiscountActive &&
      discountPrice != null &&
      discountPrice! > 0 &&
      discountPrice! < price;

  double? get originalPrice => hasDiscount ? price : null;

  List<PackageCardItem> get parsedCards {
    if (cardsRaw == null || cardsRaw!.isEmpty) {
      return [
        PackageCardItem(
          id: 'card_1',
          title: 'Tryout Utama Ujian Online',
          description: 'Simulasi ujian dengan sistem penilaian IRT',
          totalQuestions: totalQuestionsCount,
          durationMinutes: timeLimitMinutes ?? 60,
        ),
      ];
    }
    try {
      final decoded = jsonDecode(cardsRaw!);
      if (decoded is List) {
        return decoded.map((e) => PackageCardItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [
      PackageCardItem(
        id: 'card_1',
        title: 'Tryout Utama Ujian Online',
        description: 'Simulasi ujian dengan sistem penilaian IRT',
        totalQuestions: totalQuestionsCount,
        durationMinutes: timeLimitMinutes ?? 60,
      ),
    ];
  }

  int get totalModules => parsedCards.length;
  int get totalCards => totalModules;

  int get totalQuestionsCount {
    if (questionsRaw != null && questionsRaw!.isNotEmpty) {
      try {
        final decoded = jsonDecode(questionsRaw!);
        if (decoded is List) return decoded.length;
      } catch (_) {}
    }
    return 20; // default standard question count
  }

  int get totalQuestions => totalQuestionsCount;

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? json['thumbnail_url']?.toString(),
      kelas: json['kelas']?.toString() ?? json['grade_level']?.toString() ?? 'XII',
      jenjang: json['jenjang']?.toString() ?? json['category']?.toString() ?? 'SMA',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (json['discount_price'] as num?)?.toDouble() ??
          (json['discountPrice'] as num?)?.toDouble(),
      isDiscountActive: json['is_discount_active'] == true || json['isDiscountActive'] == true,
      isPayWhatYouWant: json['is_pay_what_you_want'] == true,
      minPayAmount: (json['min_pay_amount'] as num?)?.toDouble() ?? 0.0,
      membershipDurationDays: (json['membership_duration_days'] as num?)?.toInt() ??
          (json['active_days'] as num?)?.toInt() ??
          30,
      cardsRaw: json['cards'] is String
          ? json['cards']
          : (json['cards'] != null ? jsonEncode(json['cards']) : null),
      questionsRaw: json['questions'] is String
          ? json['questions']
          : (json['questions'] != null ? jsonEncode(json['questions']) : null),
      hideExplanation: json['hide_explanation'] == true,
      timeLimitMinutes: (json['time_limit_minutes'] as num?)?.toInt(),
      isActive: json['is_active'] != false,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'kelas': kelas,
      'jenjang': jenjang,
      'price': price,
      'discount_price': discountPrice,
      'is_discount_active': isDiscountActive,
      'is_pay_what_you_want': isPayWhatYouWant,
      'min_pay_amount': minPayAmount,
      'membership_duration_days': membershipDurationDays,
      'cards': cardsRaw,
      'questions': questionsRaw,
      'hide_explanation': hideExplanation,
      'time_limit_minutes': timeLimitMinutes,
      'is_active': isActive,
    };
  }
}
