class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String tag;
  final String subTag;
  final String imageUrl;
  final String? route;
  final String? externalUrl;

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.subTag,
    required this.imageUrl,
    this.route,
    this.externalUrl,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'KPM Academy',
      subtitle: json['subtitle']?.toString() ?? json['description']?.toString() ?? '',
      tag: json['tag']?.toString() ?? 'PROMO',
      subTag: json['sub_tag']?.toString() ?? json['badge']?.toString() ?? 'KPM',
      imageUrl: json['image_url']?.toString() ?? json['banner_url']?.toString() ?? '',
      route: json['route']?.toString(),
      externalUrl: json['external_url']?.toString() ?? json['link']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'tag': tag,
      'sub_tag': subTag,
      'image_url': imageUrl,
      'route': route,
      'external_url': externalUrl,
    };
  }
}
