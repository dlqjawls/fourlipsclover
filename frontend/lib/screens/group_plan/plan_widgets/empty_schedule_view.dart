import 'package:flutter/material.dart';
import '../../../config/theme.dart';

// 일정이 없을 때 표시할 빈 화면 위젯
class EmptyScheduleView extends StatelessWidget {
  final VoidCallback onAddScheduleTap;

  const EmptyScheduleView({
    Key? key,
    required this.onAddScheduleTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 72,
            color: AppColors.lightGray,
          ),
          const SizedBox(height: 16),
          Text(
            '이 날의 일정이 없습니다',
            style: TextStyle(
              fontFamily: 'Anemone_air',
              fontSize: 24,
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '새로운 일정을 추가해보세요!',
            style: TextStyle(
              fontFamily: 'Anemone_air',
              fontSize: 16,
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onAddScheduleTap,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.verylightGray,
                border: Border.all(color: AppColors.primary, width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}