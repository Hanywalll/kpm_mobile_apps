class VideoModel {
  final String id;
  final String title;
  final String description;
  final String? packageId;
  final String? videoFile;
  final String? videoUrl;
  final String? thumbnail;
  final double price;
  final String? discountType;
  final double? discountValue;
  final int accessDurationDays;
  final bool isActive;
  final bool isPayWhatYouWant;
  final double minPayAmount;

  VideoModel({
    required this.id,
    required this.title,
    this.description = '',
    this.packageId,
    this.videoFile,
    this.videoUrl,
    this.thumbnail,
    this.price = 0.0,
    this.discountType,
    this.discountValue,
    this.accessDurationDays = 30,
    this.isActive = true,
    this.isPayWhatYouWant = false,
    this.minPayAmount = 0.0,
  });

  // UI convenience getters
  String? get thumbnailUrl => safeThumbnailUrl;
  
  String get safeThumbnailUrl {
    if (thumbnail != null && thumbnail!.trim().isNotEmpty) {
      final t = thumbnail!.trim();
      if (t.startsWith('http://') || t.startsWith('https://')) {
        return t;
      }
      return 'https://backend-api.kpmacademic.io/${t.startsWith('/') ? t.substring(1) : t}';
    }
    // High-quality reliable curated learning thumbnails
    if (id.contains('1') || title.toLowerCase().contains('matematika') || title.toLowerCase().contains('logaritma')) {
      return 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=600&auto=format&fit=crop&q=80';
    } else if (id.contains('2') || title.toLowerCase().contains('tps') || title.toLowerCase().contains('logika')) {
      return 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=600&auto=format&fit=crop&q=80';
    } else if (id.contains('3') || title.toLowerCase().contains('fisika') || title.toLowerCase().contains('gerak')) {
      return 'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?w=600&auto=format&fit=crop&q=80';
    } else if (id.contains('4') || title.toLowerCase().contains('mnr') || title.toLowerCase().contains('nalaria')) {
      return 'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=600&auto=format&fit=crop&q=80';
    } else {
      return 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=600&auto=format&fit=crop&q=80';
    }
  }

  String get durationFormatted => '${accessDurationDays > 0 ? accessDurationDays : 30} Hari';
  String? get streamUrl => (videoUrl != null && videoUrl!.isNotEmpty)
      ? videoUrl
      : (videoFile != null && videoFile!.isNotEmpty ? videoFile : 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4');

  bool get isFree => price <= 0;

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      packageId: json['package_id']?.toString() ?? json['packageId']?.toString(),
      videoFile: json['video_file']?.toString() ?? json['videoFile']?.toString(),
      videoUrl: json['video_url']?.toString() ?? json['videoUrl']?.toString(),
      thumbnail: json['thumbnail']?.toString() ?? json['thumbnail_url']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discount_type']?.toString(),
      discountValue: (json['discount_value'] as num?)?.toDouble(),
      accessDurationDays: (json['access_duration_days'] as num?)?.toInt() ?? 30,
      isActive: json['is_active'] != false,
      isPayWhatYouWant: json['is_pay_what_you_want'] == true,
      minPayAmount: (json['min_pay_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'package_id': packageId,
      'video_file': videoFile,
      'video_url': videoUrl,
      'thumbnail': thumbnail,
      'price': price,
      'discount_type': discountType,
      'discount_value': discountValue,
      'access_duration_days': accessDurationDays,
      'is_active': isActive,
    };
  }
}
