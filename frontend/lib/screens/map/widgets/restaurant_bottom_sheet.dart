// lib/screens/map/widgets/restaurant_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../models/restaurant_model.dart';
import '../../../config/theme.dart';
import 'package:intl/intl.dart';

class RestaurantBottomSheet extends StatelessWidget {
  final RestaurantResponse restaurant;
  final Function(String) onRouteButtonPressed;
  final Position? currentPosition;

  const RestaurantBottomSheet({
    Key? key,
    required this.restaurant,
    required this.onRouteButtonPressed,
    this.currentPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 바텀 시트 핸들 (회색 줄)
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 상단 부분: 식당명, 해시태그, 이미지만 Row로 배치
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽: 식당명과 해시태그
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 식당명
                    Text(
                      restaurant.placeName ?? '이름 없음',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 21,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(width: 6),

                    // 해시태그 (최대 3개)
                    if (restaurant.tags != null && restaurant.tags!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: _getTagWidgets(restaurant.tags),
                        ),
                      ),
                  ],
                ),
              ),

              // // 오른쪽: 이미지
              // SizedBox(width: 12),
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(8),
              //   child: SizedBox(
              //     width: 80,
              //     height: 80,
              //     child: restaurant.restaurantImages != null &&
              //            restaurant.restaurantImages!.isNotEmpty
              //         ? Image.network(
              //             restaurant.restaurantImages!.first,
              //             fit: BoxFit.cover,
              //             errorBuilder: (_, __, ___) => _buildDefaultImage(height: 80, width: 80),
              //           )
              //         : _buildDefaultImage(height: 80, width: 80),
              //   ),
              // ),
            ],
          ),
          // 영업 정보 (전체 너비 사용)
          SizedBox(height: 16),
          _buildOperationInfo(restaurant.openingHours),

          // 점수와 거리 (전체 너비 사용)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                // 점수
                Row(
                  children: [
                    SizedBox(width: 6),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                "${(restaurant.score ?? 0.0).toStringAsFixed(0)}",
                            style: TextStyle(
                              fontFamily: 'Anemone',
                              fontSize: 17,
                              color: AppColors.primary,
                            ),
                          ),
                          TextSpan(
                            text: " 점",
                            style: TextStyle(
                              fontFamily: 'Anemone_air',
                              fontSize: 16,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // // 구분선
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 8),
                //   child: Text(
                //     "·",
                //     style: TextStyle(fontSize: 16, color: Colors.grey),
                //   ),
                // ),

                // // 거리
                // Text(
                //   _calculateDistance(),
                //   style: TextStyle(fontSize: 16, color: Colors.black),
                // ),
              ],
            ),
          ),

          // 구분선
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          ),

          // 하단 부분: 전화번호와 출발/도착 버튼 (전체 너비 사용)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 전화번호
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[700]),
                  SizedBox(width: 8),
                  Text(
                    restaurant.phone ?? '전화번호 정보 없음',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),

              // 출발/도착 버튼
              Row(
                children: [
                  // 출발 버튼
                  OutlinedButton(
                    onPressed: () {
                      if (restaurant.y != null && restaurant.x != null) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('출발지로 설정되었습니다')));
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: Size(60, 36),
                    ),
                    child: Text('출발'),
                  ),

                  SizedBox(width: 8),

                  // 도착 버튼
                  ElevatedButton(
                    onPressed: () {
                      // 도착지로 설정하고 길찾기 시작
                      onRouteButtonPressed(restaurant.kakaoPlaceId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: Size(60, 36),
                    ),
                    child: Text('도착'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 영업 정보 표시 위젯 - 영업중과 종료시간을 분리해서 표시
  Widget _buildOperationInfo(Map<String, String>? openingHours) {
    // 현재 시간
    final now = DateTime.now();
    final timeFormat = DateFormat('HH:mm');

    // 현재 요일 (영어로)
    final days = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
    ];
    final today = days[now.weekday % 7]; // 0: 일요일, 1: 월요일, ...

    // 영업 시간이 없는 경우
    if (openingHours == null || !openingHours.containsKey(today)) {
      return Text(
        "영업 시간 정보 없음",
        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
      );
    }

    // 현재 영업 시간 텍스트 (예: "07:00 - 22:00")
    final hoursText = openingHours[today] ?? "";

    // 영업 시간 파싱 (예: "07:00 - 22:00" -> 시작: 07:00, 종료: 22:00)
    final parts = hoursText.split("-").map((e) => e.trim()).toList();
    if (parts.length != 2) {
      return Text(
        hoursText,
        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
      );
    }

    // 시작 및 종료 시간 파싱
    DateTime? openTime;
    DateTime? closeTime;
    try {
      final openTimeParts = parts[0].split(":");
      final closeTimeParts = parts[1].split(":");

      if (openTimeParts.length == 2 && closeTimeParts.length == 2) {
        final openHour = int.tryParse(openTimeParts[0]);
        final openMinute = int.tryParse(openTimeParts[1]);
        final closeHour = int.tryParse(closeTimeParts[0]);
        final closeMinute = int.tryParse(closeTimeParts[1]);

        if (openHour != null &&
            openMinute != null &&
            closeHour != null &&
            closeMinute != null) {
          openTime = DateTime(
            now.year,
            now.month,
            now.day,
            openHour,
            openMinute,
          );
          closeTime = DateTime(
            now.year,
            now.month,
            now.day,
            closeHour,
            closeMinute,
          );

          // 종료 시간이 시작 시간보다 이전인 경우 (예: 22:00 - 02:00), 종료 시간을 다음 날로 설정
          if (closeTime.isBefore(openTime)) {
            closeTime = closeTime.add(Duration(days: 1));
          }
        }
      }
    } catch (e) {
      print("영업 시간 파싱 오류: $e");
    }

    // 시간 파싱에 실패한 경우
    if (openTime == null || closeTime == null) {
      return Text(
        hoursText,
        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
      );
    }

    // 현재 영업 중인지 확인
    final isOpen = now.isAfter(openTime) && now.isBefore(closeTime);

    // 다음 상태 변경 시간 계산 (영업 종료 또는 영업 시작)
    final nextChangeTime =
        isOpen ? timeFormat.format(closeTime) : timeFormat.format(openTime);

    // 영업 상태 표시 - 상태와 다음 변경 시간을 구분해서 표시
    return Row(
      children: [
        // 영업중 또는 영업종료 상태
        Text(
          isOpen ? "영업중" : "영업 종료",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isOpen ? AppColors.darkGray : AppColors.darkGray,
          ),
        ),
        SizedBox(width: 16),
        // 영업 종료 또는 시작 시간
        Text(
          isOpen ? "$nextChangeTime에 영업 종료" : "$nextChangeTime에 영업 시작",
          style: TextStyle(fontSize: 14, color: AppColors.darkGray),
        ),
      ],
    );
  }

  // 거리 계산 메서드
  String _calculateDistance() {
    // 식당 좌표가 없거나 현재 위치가 없는 경우
    if (restaurant.y == null ||
        restaurant.x == null ||
        currentPosition == null) {
      return "거리 정보 없음";
    }

    try {
      // 현재 위치와 식당 사이의 거리 계산 (미터 단위)
      final distance = Geolocator.distanceBetween(
        currentPosition!.latitude,
        currentPosition!.longitude,
        restaurant.y!,
        restaurant.x!,
      );

      return _formatDistance(distance);
    } catch (e) {
      print("거리 계산 오류: $e");
      return "거리 계산 실패";
    }
  }

  // 거리 포맷팅 (m 또는 km)
  String _formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return "${distanceInMeters.toInt()}m";
    } else {
      return "${(distanceInMeters / 1000).toStringAsFixed(1)}km";
    }
  }

  // 태그 위젯 생성 (최대 3개)
  List<Widget> _getTagWidgets(List<Map<String, dynamic>>? tags) {
    if (tags == null || tags.isEmpty) {
      return [];
    }

    // 상위 3개 태그만 표시
    return tags.take(3).map((tag) {
      return Text(
        "#${tag['tagName'] ?? ''}",
        style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
      );
    }).toList();
  }

  // 기본 이미지 위젯
  Widget _buildDefaultImage({double? height, double? width}) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 160,
      color: Colors.grey[200],
      child: Icon(Icons.restaurant, color: Colors.grey[400], size: 24),
    );
  }
}
