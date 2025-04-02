class Region {
  final int regionId;
  final String name;

  Region({
    required this.regionId,
    required this.name,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      regionId: json['regionId'],
      name: json['name'],
    );
  }
}