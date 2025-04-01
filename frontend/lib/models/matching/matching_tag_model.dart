class Tag {
  final int tagId;
  final String category;
  final String name;

  Tag({
    required this.tagId,
    required this.category,
    required this.name,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      tagId: json['tagId'],
      category: json['category'],
      name: json['name'],
    );
  }
}