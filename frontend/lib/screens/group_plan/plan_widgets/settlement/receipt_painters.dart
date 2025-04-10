// lib/screens/settlement/plan_widgets/settlement/receipt_painters.dart
import 'package:flutter/material.dart';

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
    final paint = Paint()
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
    final paint = Paint()
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