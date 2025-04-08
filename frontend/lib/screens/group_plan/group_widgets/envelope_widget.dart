// lib/screens/group_plan/group_widgets/envelope_widget.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../config/theme.dart';

class EnvelopeWidget extends StatelessWidget {
  final Animation<double> flapAnimation;
  final Animation<double> letterAnimation;
  final Animation<double> sparkleAnimation;
  final bool isEnvelopeOpen;
  final VoidCallback onTap;

  const EnvelopeWidget({
    Key? key,
    required this.flapAnimation,
    required this.letterAnimation,
    required this.sparkleAnimation,
    required this.isEnvelopeOpen,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final envelopeWidth = size.width * 0.8;
    final envelopeHeight = envelopeWidth * 0.6;

    return SizedBox(
      width: envelopeWidth,
      height: envelopeHeight,
      child: Stack(
        children: [
          // 봉투 그림자 효과 (더 깊은 그림자, 약간 확장)
          if (!isEnvelopeOpen)
            Positioned(
              left: 5,
              right: 5,
              top: 5,
              bottom: 5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 3,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),

          // 봉투 본체
          _buildEnvelopeBody(),

          // 반짝임 효과 (봉투가 열릴 때)
          AnimatedBuilder(
            animation: sparkleAnimation,
            builder: (context, child) {
              return sparkleAnimation.value > 0
                  ? Positioned.fill(
                    child: Opacity(
                      opacity: sparkleAnimation.value * 0.7,
                      child: _buildSparkles(),
                    ),
                  )
                  : Container();
            },
          ),

          // 봉투 뚜껑 (접히는 부분)
          _buildEnvelopeFlap(context),

          // 초대장 위쪽 부분 (살짝 보이는)
          AnimatedBuilder(
            animation: flapAnimation,
            builder: (context, child) {
              return flapAnimation.value > 0.8
                  ? _buildLetterPeek(context)
                  : Container();
            },
          ),
        ],
      ),
    );
  }

  // 반짝임 효과 위젯
  Widget _buildSparkles() {
    return CustomPaint(
      painter: SparklesPainter(
        progress: sparkleAnimation.value,
        color: Colors.white,
      ),
    );
  }

  // 봉투 본체
  Widget _buildEnvelopeBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryLight, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 봉투 안쪽 패턴
          Opacity(
            opacity: 0.05,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/logo.png'),
                  repeat: ImageRepeat.repeat,
                  scale: 8,
                ),
              ),
            ),
          ),

          // 봉투 측면 효과
          Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
                right: BorderSide(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          ),

          // 하단 클로버 텍스트 (음각 효과 개선)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 깊은 그림자 (바깥쪽 그림자)
                  Text(
                    '네잎클로버',
                    style: TextStyle(
                      color: Colors.transparent,
                      fontFamily: 'Anemone',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      shadows: [
                        Shadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  // 내부 그림자 효과를 위한 그라데이션 텍스트
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryLight.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ).createShader(bounds);
                    },
                    child: Text(
                      '네잎클로버',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Anemone',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  // 표면 햇빛 반사 효과 (위쪽 밝은 선)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Text(
                      '네잎클로버',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.2),
                        fontFamily: 'Anemone',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        height: 0.85, // 약간 위로 올려서 부분적으로만 보이게
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 봉투 뚜껑 (접히는 부분)
  Widget _buildEnvelopeFlap(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).size.width * 0.3, // 뚜껑 높이 (화면 너비의 30%)
      child: Transform.translate(
        offset: Offset(
          0,
          -flapAnimation.value *
              (MediaQuery.of(context).size.width * 0.3), // 더 멀리 올라가도록 수정
        ),
        child: Transform(
          alignment: Alignment.bottomCenter,
          transform:
              Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(flapAnimation.value * -3.14 / 2), // 뚜껑 회전 (90도)
          child: ClipPath(
            clipper: EnvelopeFlapClipper(),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primaryDark, AppColors.primary],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  // 봉투 패턴 효과
                  Opacity(
                    opacity: 0.05,
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/logo.png'),
                          repeat: ImageRepeat.repeat,
                          scale: 10,
                        ),
                      ),
                    ),
                  ),

                  // 봉인 스탬프 (위치와 크기 조정)
                  Center(
                    child: GestureDetector(
                      onTap: isEnvelopeOpen ? null : onTap,
                      child: Container(
                        width: 80, // 크기 증가
                        height: 80, // 크기 증가
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 60, // 내부 원 크기 증가
                            height: 60, // 내부 원 크기 증가
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.5),
                                  Colors.white.withOpacity(0.2),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryDark.withOpacity(0.3),
                                  blurRadius: 5,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // 로고
                                  Image.asset(
                                    'assets/images/logo.png',
                                    width: 40,
                                    height: 40,
                                    color: Colors.white,
                                  ),

                                  // 손가락 애니메이션 추가
                                  if (!isEnvelopeOpen)
                                    TweenAnimationBuilder<double>(
                                      tween: Tween<double>(
                                        begin: 0.0,
                                        end: 1.0,
                                      ),
                                      duration: const Duration(seconds: 6),
                                      builder: (context, value, child) {
                                        return Opacity(
                                          opacity:
                                              (math.sin(value * math.pi * 2) +
                                                  1) /
                                              2,
                                          child: Transform.translate(
                                            offset: Offset(
                                              10 *
                                                  math.cos(value * math.pi * 2),
                                              -5 *
                                                  math.sin(value * math.pi * 2),
                                            ),
                                            child: const Icon(
                                              Icons.touch_app,
                                              color: Colors.white,
                                              size: 30,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black26,
                                                  blurRadius: 5,
                                                  offset: Offset(1, 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 봉투에서 살짝 보이는 초대장
  Widget _buildLetterPeek(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.width * 0.15,
      left: 0,
      right: 0,
      height: 30, // 살짝 더 높게 설정
      child: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: flapAnimation.value > 0.9 ? letterAnimation.value : 0,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 30, // 살짝 더 높게 설정
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
              // 초대장 상단에 패턴 추가
              image: const DecorationImage(
                image: AssetImage('assets/images/logo.png'),
                alignment: Alignment.topCenter,
                scale: 20,
                repeat: ImageRepeat.repeatX,
                opacity: 0.1,
              ),
            ),
            // 살짝만 보이는 초대장 상단 문구
            child: const Center(
              child: Text(
                '초대장',
                style: TextStyle(
                  color: Colors.black26,
                  fontSize: 12,
                  fontFamily: 'Anemone',
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 커스텀 봉투 뚜껑 모양 클리퍼 - 조금 더 우아한 곡선으로 개선
class EnvelopeFlapClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // 시작점 (왼쪽 상단)
    path.moveTo(0, 0);

    // 오른쪽 상단
    path.lineTo(size.width, 0);

    // 오른쪽 하단 (곡선으로)
    path.quadraticBezierTo(
      size.width,
      size.height * 0.8,
      size.width * 0.9,
      size.height,
    );

    // 왼쪽 하단 (오른쪽과 대칭되게 곡선으로)
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 1.1,
      size.width * 0.1,
      size.height,
    );

    // 왼쪽 상단으로 완성 (오른쪽과 대칭되게)
    path.quadraticBezierTo(0, size.height * 0.8, 0, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

// 반짝임 효과를 위한 커스텀 페인터
class SparklesPainter extends CustomPainter {
  final double progress;
  final Color color;

  SparklesPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // 고정된 시드로 일관된 패턴 생성

    // 반짝임 효과 그리기
    for (int i = 0; i < 50; i++) {
      // opacity 값을 0.0 ~ 0.7 사이로 제한
      final opacity =
          (math.sin((progress + random.nextDouble()) * math.pi).abs() * 0.7)
              .clamp(0.0, 0.7);

      final paint =
          Paint()
            ..color = color.withOpacity(opacity)
            ..strokeWidth = 1 + random.nextDouble() * 2;

      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 1 + random.nextDouble() * 3;

      // 작은 원 그리기
      canvas.drawCircle(Offset(x, y), radius * progress, paint);

      // 십자가 모양의 빛줄기 추가
      if (random.nextBool()) {
        final length = radius * 4 * progress;
        canvas.drawLine(
          Offset(x - length, y),
          Offset(x + length, y),
          paint..strokeWidth = 0.5,
        );
        canvas.drawLine(
          Offset(x, y - length),
          Offset(x, y + length),
          paint..strokeWidth = 0.5,
        );
      }
    }
  }

  @override
  bool shouldRepaint(SparklesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
