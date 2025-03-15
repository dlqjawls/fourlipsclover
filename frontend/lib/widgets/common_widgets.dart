import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({Key? key, required this.currentIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(0, 'assets/icons/home', '홈'),
            _buildNavItem(1, 'assets/icons/daily_log', '데일리 로그'),
            _buildAiItem(2, 'assets/icons/ai_recommendation', 'AI 추천'), // ✅ AI 추천 버튼 애니메이션 추가
            _buildNavItem(3, 'assets/icons/group_matching', '그룹·매칭'),
            _buildNavItem(4, 'assets/icons/mypage', '마이페이지'),
          ],
        ),
      ),
    );
  }

  // 일반 네비게이션 아이템 (선택 시 약간 확대)
  Widget _buildNavItem(int index, String assetPath, String label) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: currentIndex == index
            ? (Matrix4.identity()..scale(1.1)) // ✅ 올바른 문법
            : Matrix4.identity(),
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
                fontSize: 12,
                color: currentIndex == index ? const Color(0xFF189E1E) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    ); // ✅ 여기에 세미콜론 추가하여 `AnimatedContainer`를 닫아줌
  }

  // AI 추천 버튼 (부드러운 이동 애니메이션 추가)
  Widget _buildAiItem(int index, String assetPath, String label) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: SizedBox(
        width: 50,
        height: 50,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              top: currentIndex == index ? -30 : 0, // ✅ 선택 시 부드럽게 올라감
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                curve: Curves.easeOut,
                width: currentIndex == index ? 65 : 50, // ✅ 선택 시 크기 증가
                height: currentIndex == index ? 65 : 50,
                decoration: BoxDecoration(
                  color: currentIndex == index ? const Color(0xFF189E1E) : Colors.transparent, // ✅ 초록색 원 애니메이션
                  shape: BoxShape.circle,
                  boxShadow: currentIndex == index
                      ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                      : [],
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              top: currentIndex == index ? -13 : 0, // ✅ 부드러운 아이콘 이동
              child: Image.asset(
                '$assetPath${currentIndex == index ? "_selected" : "_unselected"}.png',
                width: 24,
                height: 24,
                color: currentIndex == index ? Colors.white : Colors.grey,
              ),
            ),
            if (currentIndex != index)
              const Positioned(
                top: 30,
                child: Text(
                  'AI 추천',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
