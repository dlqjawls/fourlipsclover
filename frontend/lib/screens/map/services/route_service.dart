// lib/screens/map/services/route_service.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../providers/map_provider.dart';
import '../../../models/restaurant_model.dart';
import 'location_service.dart';

/// 경로 서비스 클래스 - 길찾기 관련 기능 캡슐화
class RouteService {
  final BuildContext context;
  final MapProvider mapProvider;
  final LocationService locationService;
  
  String? _lastOriginId;
  String? _lastDestinationId;
  
  RouteService({
    required this.context,
    required this.mapProvider,
    required this.locationService,
  });
  
  // 경로 그리기 메서드
  Future<bool> drawRouteToRestaurant({
    required String restaurantId,
    required RestaurantResponse restaurant,
    required Function(bool) setLoading,
    required Function(bool) setShowRoutePanel,
  }) async {
    // 현재 위치 확인
    Position? position = await locationService.getCurrentLocation();
    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('현재 위치를 가져올 수 없습니다')),
      );
      return false;
    }

    try {
      // 프로그레스 표시
      setLoading(true);

      // 출발지와 목적지 설정
      mapProvider.setOrigin(
        position.latitude,
        position.longitude,
        name: '현재 위치',
      );

      if (restaurant.y != null && restaurant.x != null) {
        mapProvider.setDestination(
          restaurant.y!,
          restaurant.x!,
          name: restaurant.placeName ?? '목적지',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('가게 위치 정보가 없습니다')),
        );
        setLoading(false);
        return false;
      }

      // 경로 요청
      await mapProvider.fetchRoute(
        priority: 'RECOMMEND',
        alternatives: false,
        roadDetails: true,
      );

      setLoading(false);
      setShowRoutePanel(true);

      // 길찾기 결과를 상단에 간단한 정보로 표시
      if (mapProvider.routeResponse != null &&
          mapProvider.routeResponse!.routes.isNotEmpty) {
        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('길찾기 완료: ${restaurant.placeName ?? "목적지"}까지의 경로를 표시합니다'),
            duration: Duration(seconds: 2),
          ),
        );
        return true;
      } else {
        // 오류 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('경로 요청 오류: ${mapProvider.routeError}')),
        );
        return false;
      }
    } catch (e) {
      setLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('경로 그리기 오류: $e')),
      );
      return false;
    }
  }

  // 경로 검색 메서드
  Future<bool> searchRoute({
    required Function(bool) setLoading,
  }) async {
    setLoading(true);

    try {
      // 경로 요청
      await mapProvider.fetchRoute(
        priority: 'RECOMMEND',
        alternatives: false,
        roadDetails: true,
      );
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('경로 검색 실패: $e')),
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  // 출발지와 도착지가 모두 설정되었는지 확인하고 자동으로 경로 검색
  Future<void> checkAndSearchRoute({
    required Function(bool) setLoading,
  }) async {
    // 출발지와 도착지가 모두 설정되었는지 확인
    if (mapProvider.originLabel != null &&
        mapProvider.destinationLabel != null) {
      // 이전과 다른 출발지/도착지인 경우에만 검색 실행
      final originId = mapProvider.originLabel!.id;
      final destId = mapProvider.destinationLabel!.id;

      if (originId != _lastOriginId || destId != _lastDestinationId) {
        _lastOriginId = originId;
        _lastDestinationId = destId;

        // 경로 검색 실행
        await searchRoute(setLoading: setLoading);
      }
    }
  }
  
  // 경로 및 관련 데이터 초기화
  void resetRouteState() {
    mapProvider.resetRouteState();
    _lastOriginId = null;
    _lastDestinationId = null;
  }
  
  // 출발지와 도착지 위치 교체
  Future<void> swapLocations({
    required Function(bool) setLoading,
  }) async {
    if (mapProvider.originLabel != null && mapProvider.destinationLabel != null) {
      final originLabel = mapProvider.originLabel!;
      final destLabel = mapProvider.destinationLabel!;

      mapProvider.setOrigin(
        destLabel.latitude,
        destLabel.longitude,
        name: destLabel.text,
      );

      mapProvider.setDestination(
        originLabel.latitude,
        originLabel.longitude,
        name: originLabel.text,
      );
      
      await searchRoute(setLoading: setLoading);
    }
  }
}