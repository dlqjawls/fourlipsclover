class LocalGuideTag {
  final String tagName;
  final String category;
  final int frequency;
  final double avgConfidence;

  LocalGuideTag({
    required this.tagName,
    required this.category,
    required this.frequency,
    required this.avgConfidence,
  });

  factory LocalGuideTag.fromJson(Map<String, dynamic> json) {
    return LocalGuideTag(
      tagName: json['tagName'] as String,
      category: json['category'] as String,
      frequency: json['frequency'] as int,
      avgConfidence: (json['avgConfidence'] as num).toDouble(),
    );
  }
}

class LocalGuide {
  final int id;
  final int memberId;
  final String nickname;
  final String regionName;
  final String localRegionId;
  final String localGrade;
  final String profileUrl;
  final List<LocalGuideTag> tags;
  final double rating;
  final int reviews;

  LocalGuide({
    required this.id,
    required this.memberId,
    required this.nickname,
    required this.regionName,
    required this.localRegionId,
    required this.localGrade,
    required this.profileUrl,
    required this.tags,
    this.rating = 0.0,
    this.reviews = 0,
  });

  factory LocalGuide.fromJson(Map<String, dynamic> json) {
    return LocalGuide(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      memberId: json['memberId'] is String ? int.parse(json['memberId']) : json['memberId'] as int,
      nickname: json['nickname'] as String,
      regionName: json['regionName'] as String,
      localRegionId: json['localRegionId'] as String,
      localGrade: json['localGrade'] as String,
      profileUrl: json['profileUrl'] as String,
      tags:
          (json['tags'] as List)
              .map((tag) => LocalGuideTag.fromJson(tag as Map<String, dynamic>))
              .toList(),
    );
  }
}
