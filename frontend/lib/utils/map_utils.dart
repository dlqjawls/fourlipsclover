// lib/utils/map_utils.dart
import '../providers/map_provider.dart';

class MapUtils {
  // 좌표 유효성 검사
// 명확한 이름으로 된 함수로 리팩토링
static bool isValidKoreaCoordinate(double yCoord, double xCoord) {
  // yCoord는 경도(longitude), xCoord는 위도(latitude)임

  // 한국 좌표 범위는 위도 33~43, 경도 124~132
  const minLat = 33.0;
  const maxLat = 43.0;
  const minLng = 124.0;
  const maxLng = 132.0;

  // 위도/경도 범위 검사 (매개변수 위치 바꿈)
  bool isValid = (xCoord >= minLat && xCoord <= maxLat) &&
                 (yCoord >= minLng && yCoord <= maxLng);
  
  return isValid;
}

  // 바운딩 박스 계산
  static Map<String, double> calculateBoundingBox(List<MapLabel> labels) {
    if (labels.isEmpty) {
      // 기본값 (서울 중심)
      return {
        'minLat': 37.5,
        'maxLat': 37.6,
        'minLng': 126.9,
        'maxLng': 127.0,
        'centerLat': 37.55,
        'centerLng': 126.95,
      };
    }

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (var label in labels) {
      if (label.latitude < minLat) minLat = label.latitude;
      if (label.latitude > maxLat) maxLat = label.latitude;
      if (label.longitude < minLng) minLng = label.longitude;
      if (label.longitude > maxLng) maxLng = label.longitude;
    }

    return {
      'minLat': minLat,
      'maxLat': maxLat,
      'minLng': minLng,
      'maxLng': maxLng,
      'centerLat': (minLat + maxLat) / 2,
      'centerLng': (minLng + maxLng) / 2,
    };
  }

  // 적절한 줌 레벨 계산
  static int calculateZoomLevel(double latDiff, double lngDiff) {
    // 경험적 값: 작은 값일수록 더 확대됨 (높은 줌 레벨)
    if (latDiff < 0.01 && lngDiff < 0.01) return 17; // 매우 가까운 거리
    if (latDiff < 0.05 && lngDiff < 0.05) return 15; // 가까운 거리
    if (latDiff < 0.1 && lngDiff < 0.1) return 14; // 중간 거리
    if (latDiff < 0.5 && lngDiff < 0.5) return 12; // 먼 거리
    return 10; // 매우 먼 거리
  }

  // 라벨 ID 생성
  static String generateLabelId(String? prefix, String? id) {
    return id ??
        '${prefix ?? "label"}_${DateTime.now().millisecondsSinceEpoch}';
  }
}
