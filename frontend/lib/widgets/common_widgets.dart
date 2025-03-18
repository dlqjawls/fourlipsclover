import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({Key? key, required this.currentIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ✅ 맛집 버튼 선택 시만 둥근 보더 적용
        if (currentIndex == 2)
          Positioned.fill(
            child: CustomPaint(
              painter: RoundedBorderPainter(),
            ),
          ),
        Container(
          height: 75,
          decoration: BoxDecoration(
            color: Colors.white,
            border: currentIndex == 2
                ? null // ✅ 맛집 선택 시 기존 보더 제거
                : const Border(top: BorderSide(color: Color(0xFFF3F3F3), width: 0.5)), // 기본 직선 보더 유지
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, 'assets/icons/group', '그룹'),
              _buildNavItem(1, 'assets/icons/matching', '매칭'),
              _buildAiItem(2, 'assets/icons/recommendation', '맛집'),
              _buildNavItem(3, 'assets/icons/daily_log', '스토리'),
              _buildNavItem(4, 'assets/icons/mypage', '마이'),
            ],
          ),
        ),
      ],
    );
  }

  // 일반 네비게이션 아이템
  Widget _buildNavItem(int index, String assetPath, String label) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            '$assetPath${currentIndex == index ? "_selected" : "_unselected"}.png',
            width: 24,
            height: 24,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // AI 추천 버튼 (맛집 버튼)
  Widget _buildAiItem(int index, String assetPath, String label) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: SizedBox(
        width: 40,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // ✅ 초록색 원 (애니메이션)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              top: currentIndex == index ? -10 : -10,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                curve: Curves.easeOut,
                width: currentIndex == index ? 50 : 0,
                height: currentIndex == index ? 50 : 0,
                decoration: BoxDecoration(
                  color: currentIndex == index ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // 아이콘
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              top: currentIndex == index ? 0 : 0,
              child: Image.asset(
                '$assetPath${currentIndex == index ? "_selected" : "_unselected"}.png',
                width: 24,
                height: 24,
                color: currentIndex == index ? Colors.black : AppColors.darkGray,
              ),
            ),
            // ✅ "맛집" 선택 시 텍스트 숨김
            if (currentIndex != index)
              Positioned(
                top: 29,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.darkGray,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ✅ 둥근 보더 배경을 그리는 CustomPainter (맛집 선택 시만 적용)
class RoundedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Color(0xFFF3F3F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();
    final double width = size.width;
    final double height = size.height;
    final double notchWidth = 52; // 둥근 부분의 너비
    final double notchHeight = 20; // 둥근 부분의 높이
    final double centerX = width * 0.5 - 1; // 가운데 정렬

    // ✅ 둥근 보더 영역 그리기
    path.moveTo(0, 0);
    path.lineTo(centerX - notchWidth / 2, 0);
    path.quadraticBezierTo(centerX, -notchHeight, centerX + notchWidth / 2, 0);
    path.lineTo(width, 0);
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
