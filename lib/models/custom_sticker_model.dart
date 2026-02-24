/// Model for custom user-created stickers
class CustomStickerModel {
  final String id;
  final String filePath;
  final String name;
  final String? description;
  final DateTime createdAt;
  final String category;
  final int? fileSize;
  final double? width;
  final double? height;

  CustomStickerModel({
    required this.id,
    required this.filePath,
    required this.name,
    this.description,
    required this.createdAt,
    this.category = 'Mes stickers',
    this.fileSize,
    this.width,
    this.height,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
      'fileSize': fileSize,
      'width': width,
      'height': height,
    };
  }

  // Create from JSON
  factory CustomStickerModel.fromJson(Map<String, dynamic> json) {
    return CustomStickerModel(
      id: json['id'] as String,
      filePath: json['filePath'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      category: json['category'] as String? ?? 'Mes stickers',
      fileSize: json['fileSize'] as int?,
      width: json['width'] as double?,
      height: json['height'] as double?,
    );
  }

  // Create a copy with modified fields
  CustomStickerModel copyWith({
    String? id,
    String? filePath,
    String? name,
    String? description,
    DateTime? createdAt,
    String? category,
    int? fileSize,
    double? width,
    double? height,
  }) {
    return CustomStickerModel(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      fileSize: fileSize ?? this.fileSize,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
