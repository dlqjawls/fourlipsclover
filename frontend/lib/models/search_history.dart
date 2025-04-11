// lib/models/search_history.dart
class SearchHistory {
  final String query;
  final String date;

  SearchHistory({
    required this.query,
    required this.date,
  });

  // JSON 변환을 위한 메소드 추가
  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'date': date,
    };
  }

  // JSON에서 객체 생성을 위한 팩토리 메소드
  factory SearchHistory.fromJson(Map<String, dynamic> json) {
    return SearchHistory(
      query: json['query'],
      date: json['date'],
    );
  }
}