// lib/models/analysis/category_analysis_model.dart
class CategoryAnalysisResult {
  final int totalVisits;
  final int totalAmount;
  final Map<String, int> categoryVisits;
  final Map<String, int> categorySpending;

  CategoryAnalysisResult({
    required this.totalVisits,
    required this.totalAmount,
    required this.categoryVisits,
    required this.categorySpending,
  });

  factory CategoryAnalysisResult.fromJson(Map<String, dynamic> json) {
    // Map의 Key는 String, Value는 int로 변환
    Map<String, int> categoryVisits = (json['categoryVisits'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value as int));

    Map<String, int> categorySpending = (json['categorySpending'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value as int));

    return CategoryAnalysisResult(
      totalVisits: json['totalVisits'],
      totalAmount: json['totalAmount'],
      categoryVisits: categoryVisits,
      categorySpending: categorySpending,
    );
  }

  // 카테고리별 평균 지출액 계산
  double getCategoryAverageSpending(String category) {
    int visits = categoryVisits[category] ?? 0;
    int spending = categorySpending[category] ?? 0;
    
    if (visits == 0) return 0;
    return spending / visits;
  }

  // 카테고리별 지출 비율 계산
  double getCategorySpendingPercentage(String category) {
    int spending = categorySpending[category] ?? 0;
    
    if (totalAmount == 0) return 0;
    return spending / totalAmount * 100;
  }

  // 모든 카테고리 이름 리스트
  List<String> get categories => categorySpending.keys.toList();
}