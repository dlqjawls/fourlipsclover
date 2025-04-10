// lib/models/tag_model.dart
class TagModel {
  final int tagId;
  final String category;
  final String name;

  TagModel({
    required this.tagId,
    required this.category,
    required this.name,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      tagId: json['tagId'],
      category: json['category'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tagId': tagId,
      'category': category,
      'name': name,
    };
  }

  @override
  String toString() {
    return name;
  }
}