// lib/screens/map/services/label_service.dart
import 'package:flutter/material.dart';
import '../../../providers/map_provider.dart';
import '../../../services/kakao_map_service.dart';
import '../../../models/restaurant_model.dart';

/// 라벨 서비스 클래스 - 지도 라벨 관련 기능 캡슐화
class LabelService {
  final BuildContext context;
  final MapProvider mapProvider;

  LabelService({required this.context, required this.mapProvider});

  // 네이티브 지도에 라벨 추가 메서드

Future<Map<String, RestaurantResponse>> addLabelsToMap({
  required bool mapInitialized,
  required Function(bool) setLoading,
  String userLocationLabelId = 'user_location_marker',
}) async {
  if (!mapInitialized) return {};
  
  setLoading(true);
  
  final labels = mapProvider.labels;
  final Map<String, RestaurantResponse> restaurantData = {};
  
  if (labels.isEmpty) {
    setLoading(false);
    return restaurantData;
  }
  
  try {
    // 기존 라벨 모두 제거 (네이티브 레벨)
    await KakaoMapPlatform.clearLabels();
    
    // 모든 라벨을 네이티브에 추가
    for (var label in labels) {
      try {
        // 사용자 위치 마커는 건너뛰기
        if (label.id == userLocationLabelId) continue;
        
        await KakaoMapPlatform.addLabel(
          labelId: label.id,
          latitude: label.latitude,
          longitude: label.longitude,
          text: label.text,
          imageAsset: label.imageAsset,
          textSize: label.textSize,
          alpha: label.alpha ?? 1.0,
          rotation: label.rotation ?? 0.0,
          zIndex: label.zIndex,
          isClickable: label.isClickable,
        );
        
        // 라벨이 RestaurantResponse 타입의 경우 가게 데이터에 저장
        // 더 많은 데이터를 포함하도록 수정
        var restaurantInfo = RestaurantResponse(
          kakaoPlaceId: label.id,
          placeName: label.text,
          x: label.longitude,
          y: label.latitude,
          addressName: '주소 정보가 없습니다',
          roadAddressName: '도로명 주소 정보가 없습니다',
          category: '카테고리 정보가 없습니다',
          categoryName: '카테고리 정보가 없습니다',
          phone: '전화번호 정보가 없습니다',
          placeUrl: '',
          restaurantImages: [],
          menu: [],
          avgAmount: null,
          likeSentiment: 0,
          dislikeSentiment: 0,
        );
        
        restaurantData[label.id] = restaurantInfo;
        
        // 각 라벨 추가 사이에 짧은 딜레이 (UI에서 더 잘 보이도록)
        await Future.delayed(Duration(milliseconds: 50));
      } catch (e) {
        print('라벨 추가 오류: ${label.id} - $e');
      }
    }
    
    print('지도에 ${labels.length}개의 라벨 추가 완료');
  } catch (e) {
    print('라벨 추가 중 오류 발생: $e');
  } finally {
    setLoading(false);
  }
  
  return restaurantData;
}

  // 지도 중심 설정
  Future<void> centerMapOnRestaurant(RestaurantResponse restaurant) async {
    if (restaurant.y != null && restaurant.x != null) {
      await KakaoMapPlatform.setMapCenter(
        latitude: restaurant.y!,
        longitude: restaurant.x!,
        zoomLevel: 16, // 적절한 줌 레벨 설정
      );
    }
  }
}
