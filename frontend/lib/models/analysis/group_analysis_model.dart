// lib/models/analysis/group_analysis_model.dart
import 'dart:convert';

class GroupAnalysisResult {
  final int groupId;
  final Map<String, AnalysisType> analyses;

  GroupAnalysisResult({
    required this.groupId,
    required this.analyses,
  });

  factory GroupAnalysisResult.fromJson(Map<String, dynamic> json) {
    Map<String, AnalysisType> analysesMap = {};
    
    final analysesJson = json['analyses'] as Map<String, dynamic>;
    
    analysesJson.forEach((key, value) {
      try {
        switch (key) {
          case 'basic_comparison':
            analysesMap[key] = BasicComparison.fromJson(value);
            break;
          case 'personnel_comparison':
            analysesMap[key] = PersonnelComparison.fromJson(value);
            break;
          case 'time_comparison':
            analysesMap[key] = TimeComparison.fromJson(value);
            break;
          case 'day_of_week_comparison':
            analysesMap[key] = DayOfWeekComparison.fromJson(value);
            break;
          default:
            // Handle unknown analysis type
            print('Unknown analysis type: $key');
            break;
        }
      } catch (e) {
        print('Error parsing $key analysis: $e');
      }
    });

    return GroupAnalysisResult(
      groupId: json['group_id'],
      analyses: analysesMap,
    );
  }
}

abstract class AnalysisType {
  final int groupId;
  final String analysisId;
  final String timestamp;
  
  AnalysisType({
    required this.groupId,
    required this.analysisId,
    required this.timestamp,
  });
}

class BasicComparison extends AnalysisType {
  final List<BasicComparisonData> data;

  BasicComparison({
    required super.groupId,
    required super.analysisId,
    required super.timestamp,
    required this.data,
  });

  factory BasicComparison.fromJson(Map<String, dynamic> json) {
    List<dynamic> dataList = _parseAnalysisData(json['analysis_data']);
    List<BasicComparisonData> data = dataList
        .map((item) => BasicComparisonData.fromJson(item))
        .toList();

    return BasicComparison(
      groupId: json['group_id'],
      analysisId: json['analysis_id'],
      timestamp: json['timestamp'],
      data: data,
    );
  }
}

class BasicComparisonData {
  final String groupType;
  final double avgSpending;
  final int totalSpending;
  final int transactionCount;
  final int groupId;
  final String timestamp;
  final String analysisType;

  BasicComparisonData({
    required this.groupType,
    required this.avgSpending,
    required this.totalSpending,
    required this.transactionCount,
    required this.groupId,
    required this.timestamp,
    required this.analysisType,
  });

  factory BasicComparisonData.fromJson(Map<String, dynamic> json) {
    return BasicComparisonData(
      groupType: json['group_type'],
      avgSpending: (json['avg_spending'] is int) 
          ? (json['avg_spending'] as int).toDouble() 
          : json['avg_spending'],
      totalSpending: json['total_spending'],
      transactionCount: json['transaction_count'],
      groupId: json['group_id'],
      timestamp: json['timestamp'],
      analysisType: json['analysis_type'],
    );
  }
}

class PersonnelComparison extends AnalysisType {
  final List<PersonnelComparisonData> data;

  PersonnelComparison({
    required super.groupId,
    required super.analysisId,
    required super.timestamp,
    required this.data,
  });

  factory PersonnelComparison.fromJson(Map<String, dynamic> json) {
    List<dynamic> dataList = _parseAnalysisData(json['analysis_data']);
    List<PersonnelComparisonData> data = dataList
        .map((item) => PersonnelComparisonData.fromJson(item))
        .toList();

    return PersonnelComparison(
      groupId: json['group_id'],
      analysisId: json['analysis_id'],
      timestamp: json['timestamp'],
      data: data,
    );
  }
}

class PersonnelComparisonData {
  final int visitedPersonnel;
  final String groupType;
  final double avgSpending;
  final int visitCount;
  final int groupId;
  final String timestamp;
  final String analysisType;

  PersonnelComparisonData({
    required this.visitedPersonnel,
    required this.groupType,
    required this.avgSpending,
    required this.visitCount,
    required this.groupId,
    required this.timestamp,
    required this.analysisType,
  });

  factory PersonnelComparisonData.fromJson(Map<String, dynamic> json) {
    return PersonnelComparisonData(
      visitedPersonnel: json['visited_personnel'],
      groupType: json['group_type'],
      avgSpending: (json['avg_spending'] is int) 
          ? (json['avg_spending'] as int).toDouble() 
          : json['avg_spending'],
      visitCount: json['visit_count'],
      groupId: json['group_id'],
      timestamp: json['timestamp'],
      analysisType: json['analysis_type'],
    );
  }
}

class TimeComparison extends AnalysisType {
  final List<TimeComparisonData> data;

  TimeComparison({
    required super.groupId,
    required super.analysisId,
    required super.timestamp,
    required this.data,
  });

  factory TimeComparison.fromJson(Map<String, dynamic> json) {
    List<dynamic> dataList = _parseAnalysisData(json['analysis_data']);
    List<TimeComparisonData> data = dataList
        .map((item) => TimeComparisonData.fromJson(item))
        .toList();

    return TimeComparison(
      groupId: json['group_id'],
      analysisId: json['analysis_id'],
      timestamp: json['timestamp'],
      data: data,
    );
  }
}

class TimeComparisonData {
  final int hourOfDay;
  final String groupType;
  final double avgSpending;
  final int visitCount;
  final int groupId;
  final String timestamp;
  final String analysisType;

  TimeComparisonData({
    required this.hourOfDay,
    required this.groupType,
    required this.avgSpending,
    required this.visitCount,
    required this.groupId,
    required this.timestamp,
    required this.analysisType,
  });

  factory TimeComparisonData.fromJson(Map<String, dynamic> json) {
    return TimeComparisonData(
      hourOfDay: json['hour_of_day'],
      groupType: json['group_type'],
      avgSpending: (json['avg_spending'] is int) 
          ? (json['avg_spending'] as int).toDouble() 
          : json['avg_spending'],
      visitCount: json['visit_count'],
      groupId: json['group_id'],
      timestamp: json['timestamp'],
      analysisType: json['analysis_type'],
    );
  }
}

class DayOfWeekComparison extends AnalysisType {
  final List<DayOfWeekComparisonData> data;

  DayOfWeekComparison({
    required super.groupId,
    required super.analysisId,
    required super.timestamp,
    required this.data,
  });

  factory DayOfWeekComparison.fromJson(Map<String, dynamic> json) {
    List<dynamic> dataList = _parseAnalysisData(json['analysis_data']);
    List<DayOfWeekComparisonData> data = dataList
        .map((item) => DayOfWeekComparisonData.fromJson(item))
        .toList();

    return DayOfWeekComparison(
      groupId: json['group_id'],
      analysisId: json['analysis_id'],
      timestamp: json['timestamp'],
      data: data,
    );
  }
}

class DayOfWeekComparisonData {
  final int dayOfWeek;
  final String groupType;
  final double avgSpending;
  final int visitCount;
  final int groupId;
  final String timestamp;
  final String analysisType;

  DayOfWeekComparisonData({
    required this.dayOfWeek,
    required this.groupType,
    required this.avgSpending,
    required this.visitCount,
    required this.groupId,
    required this.timestamp,
    required this.analysisType,
  });

  factory DayOfWeekComparisonData.fromJson(Map<String, dynamic> json) {
    return DayOfWeekComparisonData(
      dayOfWeek: json['day_of_week'],
      groupType: json['group_type'],
      avgSpending: (json['avg_spending'] is int) 
          ? (json['avg_spending'] as int).toDouble() 
          : json['avg_spending'],
      visitCount: json['visit_count'],
      groupId: json['group_id'],
      timestamp: json['timestamp'],
      analysisType: json['analysis_type'],
    );
  }
}

// 안전하게 analysis_data를 파싱하는 헬퍼 메서드
List<dynamic> _parseAnalysisData(dynamic analysisData) {
  try {
    if (analysisData is String) {
      // 문자열인 경우 JSON 디코딩 시도
      return jsonDecode(analysisData);
    } else if (analysisData is List) {
      // 이미 리스트인 경우 그대로 사용
      return analysisData;
    } else {
      // 다른 타입이면 빈 리스트 반환
      print('Unexpected analysis_data type: ${analysisData.runtimeType}');
      return [];
    }
  } catch (e) {
    print('Error parsing analysis_data: $e');
    return [];
  }
}

// 요일 이름 변환 헬퍼 메서드
String getDayOfWeekName(int dayOfWeek) {
  switch (dayOfWeek) {
    case 1:
      return '월요일';
    case 2:
      return '화요일';
    case 3:
      return '수요일';
    case 4:
      return '목요일';
    case 5:
      return '금요일';
    case 6:
      return '토요일';
    case 7:
      return '일요일';
    default:
      return '알 수 없음';
  }
}