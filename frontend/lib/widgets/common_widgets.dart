import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (currentIndex == 2)
          Positioned.fill(child: CustomPaint(painter: RoundedBorderPainter())),
        SafeArea(
          // ✅ SafeArea 열고
          top: false,
          child: Container(
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  currentIndex == 2
                      ? null
                      : const Border(
                        top: BorderSide(color: Color(0xFFF3F3F3), width: 0.5),
                      ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // 여긴 유지해도 됨
              children: [
                Flexible(child: _buildNavItem(0, 'assets/icons/group', '그룹')),
                Flexible(
                  child: _buildNavItem(1, 'assets/icons/matching', '매칭'),
                ),
                Flexible(
                  child: _buildAiItem(2, 'assets/icons/recommendation', '맛집'),
                ),
                Flexible(child: _buildNavItem(3, 'assets/icons/chat', '채팅')),
                Flexible(child: _buildNavItem(4, 'assets/icons/mypage', '마이')),
              ],
            ),
          ),
        ), // ✅ SafeArea 닫기
      ],
    );
  }

  // 일반 네비게이션 아이템
  Widget _buildNavItem(int index, String assetPath, String label) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: 80,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ✅ 아이콘 애니메이션 적용!
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180), // ← 속도도 자연스럽게
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Image.asset(
                '$assetPath${currentIndex == index ? "_selected" : "_unselected"}.png',
                key: ValueKey(currentIndex == index),
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 40, // 텍스트 길이에 관계 없이 아이콘 아래 정렬 유지
              alignment: Alignment.center,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: AppColors.darkGray),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // AI 추천 버튼 (맛집 버튼)
  // ✅ 교체: 자연스러운 효과 적용된 AI 추천 버튼
  Widget _buildAiItem(int index, String assetPath, String label) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: 80,
        alignment: Alignment.center,
        child: SizedBox(
          width: 40,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // ✅ 초록색 애니메이션 원
              // 새로운 코드 - 중심에서 부풀듯이 커지는 초록 원
              Positioned(
                top: -10,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child:
                      currentIndex == index
                          ? Container(
                            key: const ValueKey('green'),
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          )
                          : const SizedBox.shrink(key: ValueKey('none')),
                ),
              ),

              // ✅ 아이콘 교차 전환 애니메이션
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                top: 0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child:
                      currentIndex == index
                          ? Image.asset(
                            '${assetPath}_selected.png',
                            key: const ValueKey('selected'),
                            width: 24,
                            height: 24,
                            color: Colors.black,
                          )
                          : Image.asset(
                            '${assetPath}_unselected.png',
                            key: const ValueKey('unselected'),
                            width: 24,
                            height: 24,
                            color: AppColors.darkGray,
                          ),
                ),
              ),

              // ✅ 텍스트는 선택 안 됐을 때만 보여줌
              if (currentIndex != index)
                Positioned(
                  top: 29,
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 10, color: AppColors.darkGray),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ 둥근 보더 배경을 그리는 CustomPainter (맛집 선택 시만 적용)
class RoundedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final borderPaint =
        Paint()
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
