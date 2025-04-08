// lib/screens/group_plan/group_widgets/invitation_content_widget.dart
import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class InvitationContentWidget extends StatefulWidget {
  final Map<String, dynamic> invitationInfo;
  final VoidCallback onJoin;
  final VoidCallback onPostpone;
  final VoidCallback onDecline;

  const InvitationContentWidget({
    Key? key,
    required this.invitationInfo,
    required this.onJoin,
    required this.onPostpone,
    required this.onDecline,
  }) : super(key: key);

  @override
  State<InvitationContentWidget> createState() =>
      _InvitationContentWidgetState();
}

class _InvitationContentWidgetState extends State<InvitationContentWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _buttonScaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 0.8, curve: Curves.elasticOut),
    );

    // 애니메이션 자동 시작
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: _buildContent(),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    final groupName = widget.invitationInfo['groupName'] ?? '알 수 없는 그룹';
    final description = widget.invitationInfo['description'] ?? '';
    final ownerName = widget.invitationInfo['ownerName'] ?? '알 수 없음';
    final memberCount = widget.invitationInfo['memberCount'] ?? 0;

    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 초대 헤더
            _buildInvitationHeader(groupName),

            const SizedBox(height: 24),

            // 초대 내용
            Text(
              '안녕하세요!\n$ownerName님이 회원님을 그룹에 초대했습니다.',
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                fontFamily: 'Anemone_air',
              ),
            ),

            const SizedBox(height: 16),

            // 그룹 설명
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.verylightGray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightGray, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppColors.primaryDark,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '그룹 정보',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        '현재 멤버: $memberCount명',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 버튼 영역
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  // 초대 헤더 위젯
  Widget _buildInvitationHeader(String groupName) {
    return Column(
      children: [
        // 물결 효과가 있는 헤더
        Stack(
          alignment: Alignment.center,
          children: [
            // 물결 패턴 배경
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: WavePatternPainter(
                  color: AppColors.primary.withOpacity(0.1),
                ),
                size: const Size(double.infinity, 40),
              ),
            ),

            // 클로버 로고
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 40,
                height: 40,
                color: AppColors.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 그룹 이름
        Text(
          groupName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGray,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 5),

        // 초대장 서브타이틀
        Text(
          '그룹 초대장',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        // 구분선
        Divider(color: AppColors.lightGray, thickness: 1),
      ],
    );
  }

  // 버튼 영역 위젯
  Widget _buildButtons() {
    return Column(
      children: [
        // 참여 버튼 (더 강조)
        Transform.scale(
          scale: _buttonScaleAnimation.value,
          child: ElevatedButton(
            onPressed: widget.onJoin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 18),
                SizedBox(width: 8),
                Text(
                  '그룹 참여하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 하단 버튼 영역
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 나중에 버튼
            Transform.scale(
              scale: _buttonScaleAnimation.value,
              child: TextButton(
                onPressed: widget.onPostpone,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.darkGray,
                ),
                child: const Text('나중에 생각하기'),
              ),
            ),

            const SizedBox(width: 16),

            // 거절 버튼
            Transform.scale(
              scale: _buttonScaleAnimation.value,
              child: TextButton(
                onPressed: widget.onDecline,
                style: TextButton.styleFrom(foregroundColor: AppColors.red),
                child: const Text('초대 거절하기'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 물결 패턴을 그리는 CustomPainter
class WavePatternPainter extends CustomPainter {
  final Color color;

  WavePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final path = Path();
    final height = size.height;
    final width = size.width;

    final segmentWidth = width / 8;

    path.moveTo(0, height / 2);

    for (int i = 0; i < 8; i++) {
      // 파도처럼 위아래로 이어지는 곡선
      if (i % 2 == 0) {
        path.quadraticBezierTo(
          segmentWidth * i + segmentWidth / 2,
          height * 0.75,
          segmentWidth * (i + 1),
          height / 2,
        );
      } else {
        path.quadraticBezierTo(
          segmentWidth * i + segmentWidth / 2,
          height * 0.25,
          segmentWidth * (i + 1),
          height / 2,
        );
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
