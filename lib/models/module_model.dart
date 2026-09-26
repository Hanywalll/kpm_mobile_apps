class ModuleModel {
  final String id;
  final String title;
  final String description;
  final String tag;
  final int totalChapters;
  final String fileUrl;
  final String fileSize;

  ModuleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.tag,
    required this.totalChapters,
    required this.fileUrl,
    required this.fileSize,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Modul Pembelajaran',
      description: json['description']?.toString() ?? json['subtitle']?.toString() ?? 'Modul materi MNR & Sains',
      tag: json['tag']?.toString() ?? json['category']?.toString() ?? 'Materi',
      totalChapters: int.tryParse(json['total_chapters']?.toString() ?? '') ?? 4,
      fileUrl: json['file_url']?.toString() ?? json['pdf_url']?.toString() ?? '',
      fileSize: json['file_size']?.toString() ?? '2.4 MB',
    );
  }
}
