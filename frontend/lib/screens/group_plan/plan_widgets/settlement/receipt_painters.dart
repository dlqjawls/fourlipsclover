// lib/screens/settlement/plan_widgets/settlement/receipt_painters.dart
import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

/// 테이프 모양을 위한 클리퍼
class TapeClipper extends CustomClipper<Path> {
  const TapeClipper();

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.5); // 왼쪽 하단 모서리에서 시작
    path.lineTo(size.width * 0.1, 0); // 왼쪽 상단 모서리
    path.lineTo(size.width, 0); // 오른쪽 상단 모서리
    path.lineTo(size.width, size.height); // 오른쪽 하단 모서리
    path.lineTo(size.width * 0.1, size.height); // 왼쪽 하단 모서리
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// 점선 그리기 위한 CustomPainter
class DottedLinePainter extends CustomPainter {
  const DottedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    double dashWidth = 5, dashSpace = 5, startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// 바코드 그리기 위한 CustomPainter
class BarcodePainter extends CustomPainter {
  const BarcodePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;

    final random = List.generate(
      50,
      (index) => index * 3.0 + (index % 3) * 2.0,
    );
    double startX = 0;

    for (int i = 0; i < random.length; i++) {
      // 각 바코드 라인의 두께와 간격 설정
      final lineWidth = i % 4 == 0 ? 3.0 : 1.5;
      final spaceWidth = 2.0;

      // 바코드 선 그리기
      canvas.drawRect(Rect.fromLTWH(startX, 0, lineWidth, size.height), paint);

      startX += lineWidth + spaceWidth;

      // 바코드가 영역을 벗어나면 그리기 중단
      if (startX > size.width) break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 바코드 위에 표시되는 스캔 라인 애니메이션 위젯
class ScanningLine extends StatefulWidget {
  final bool isEnabled;

  const ScanningLine({Key? key, this.isEnabled = true}) : super(key: key);

  @override
  State<ScanningLine> createState() => _ScanningLineState();
}

class _ScanningLineState extends State<ScanningLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 스캔 애니메이션 - 왼쪽에서 오른쪽으로 이동
    _scanAnimation = Tween<double>(begin: -5, end: 205).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 애니메이션 반복 (앞뒤로 움직임)
    if (widget.isEnabled) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ScanningLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 위젯 속성이 변경될 때 애니메이션 상태 업데이트
    if (widget.isEnabled != oldWidget.isEnabled) {
      if (widget.isEnabled) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) {
      return const SizedBox.shrink(); // 활성화되지 않은 경우 표시하지 않음
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          left: _scanAnimation.value,
          top: 0,
          bottom: 0,
          child: Container(
            width: 2,
            decoration: BoxDecoration(
              color: AppColors.red.withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.red.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
