// lib/screens/group_plan/bottomsheet/custom_time_picker.dart
import 'package:flutter/material.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import '../../../config/theme.dart';

class CustomTimePicker {
  /// day_night_time_picker 라이브러리를 사용한 시간 선택 다이얼로그를 표시합니다.
  /// 한국어 지원 및 한국식 시간 표기를 적용합니다.
  ///
  /// [context] 현재 빌드 컨텍스트
  /// [initialTime] 초기 시간 값
  /// [onTimeSelected] 사용자가 시간을 선택했을 때 호출되는 콜백
  static Future<void> show({
    required BuildContext context,
    required TimeOfDay initialTime,
    required Function(TimeOfDay) onTimeSelected,
  }) async {
    Navigator.of(context).push(
      showPicker(
        context: context,
        value: Time(hour: initialTime.hour, minute: initialTime.minute),
        onChange: (Time newTime) {
          // Time 객체를 TimeOfDay로 변환
          final timeOfDay = TimeOfDay(
            hour: newTime.hour,
            minute: newTime.minute,
          );
          onTimeSelected(timeOfDay);
        },
        minuteInterval: TimePickerInterval.TEN,
        // 타임피커 핵심 설정
        is24HrFormat: false, // 12시간제 사용
        disableHour: false, // 시간 선택 활성화
        disableMinute: false, // 분 선택 활성화
        // UI 스타일링
        accentColor: AppColors.primary, // 강조 색상
        unselectedColor: Colors.grey, // 선택되지 않은 항목 색상
        barrierColor: Colors.black45, // 배경 overlay 색상
        borderRadius: 16, // 컨테이너 모서리 둥글기
        elevation: 8, // 그림자 강도
        // 버튼 설정
        cancelText: '취소', // 취소 버튼 텍스트
        okText: '확인', // 확인 버튼 텍스트
        // 헤더 설정
        displayHeader: true, // 헤더 표시
        // 커스텀 이미지 설정
        sunAsset: Image.asset('assets/images/rice.png', width: 80, height: 80),
        moonAsset: Image.asset('assets/images/beer.png', width: 90, height: 90),
        // 레이아웃 설정
        dialogInsetPadding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 24.0,
        ),

        // 테마 설정
        themeData: ThemeData(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.primary,
            onSurface: Colors.black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
