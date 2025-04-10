// lib/screens/settlement/widgets/expense_molbbang_widget.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../config/theme.dart';
import '../../../../models/settlement/settlement_model.dart';

class ExpenseMolbbangWidget extends StatefulWidget {
  final List<ExpenseParticipant> participants;
  final Function(int) onSelectParticipant;
  final ExpenseParticipant? selectedParticipant;

  const ExpenseMolbbangWidget({
    Key? key,
    required this.participants,
    required this.onSelectParticipant,
    this.selectedParticipant,
  }) : super(key: key);

  @override
  _ExpenseMolbbangWidgetState createState() => _ExpenseMolbbangWidgetState();
}

class _ExpenseMolbbangWidgetState extends State<ExpenseMolbbangWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<MolbbangBall> _balls = [];
  bool _isSpinning = false;
  late AnimationController _resultController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int? _selectedParticipantIndex;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 설정
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _resultController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _resultController, curve: Curves.easeIn));

    // 프로필 공 생성
    _initializeBalls();
  }

  @override
  void didUpdateWidget(ExpenseMolbbangWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 참여자 목록이 변경된 경우 공 재생성
    if (widget.participants.length != oldWidget.participants.length) {
      _initializeBalls();
    }
  }

  void _initializeBalls() {
    final random = Random();
    final screenWidth = 250.0;
    final screenHeight = 200.0;

    _balls = List.generate(widget.participants.length, (index) {
      return MolbbangBall(
        id: index,
        participant: widget.participants[index],
        initialPosition: Offset(
          random.nextDouble() * screenWidth,
          random.nextDouble() * screenHeight,
        ),
        initialVelocity: Offset(
          (random.nextDouble() - 0.5) * 8, // 속도 X
          (random.nextDouble() - 0.5) * 8, // 속도 Y
        ),
        controller: _controller,
      );
    });
  }

  void _startMolbbang() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _selectedParticipantIndex = null;
    });

    _controller.forward(from: 0.0);

    // 2초 후 최종 선택
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _selectedParticipantIndex = Random().nextInt(
          widget.participants.length,
        );
        _isSpinning = false;
      });

      widget.onSelectParticipant(
        widget.participants[_selectedParticipantIndex!].memberId,
      );
      _resultController.forward(from: 0.0); // 결과 카드 애니메이션 시작!
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.verylightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 로또 볼 애니메이션
          ...List.generate(_balls.length, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final selectedAnimation =
                    _selectedParticipantIndex == index
                        ? _scaleAnimation.value
                        : 1.0;

                return Positioned(
                  left: _balls[index].position.dx,
                  top: _balls[index].position.dy,
                  child: Transform.scale(
                    scale:
                        _selectedParticipantIndex == index
                            ? selectedAnimation
                            : 1.0,
                    child: _buildProfileBall(
                      _balls[index],
                      isSelected: _selectedParticipantIndex == index,
                      isCurrentlySelected:
                          widget.selectedParticipant?.memberId ==
                          _balls[index].participant.memberId,
                    ),
                  ),
                );
              },
            );
          }),

          // 뽑기 버튼
          Positioned(
            bottom: 0,
            child: ElevatedButton(
              onPressed:
                  widget.selectedParticipant != null
                      ? null
                      : (_isSpinning ? null : _startMolbbang),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    widget.selectedParticipant != null
                        ? AppColors.mediumGray
                        : AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                widget.selectedParticipant != null
                    ? '몰빵 확정: ${widget.selectedParticipant!.nickname}'
                    : (_isSpinning ? '몰빵 중...' : '랜덤 몰빵하기'),
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Anemone_air',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileBall(
    MolbbangBall ball, {
    bool isSelected = false,
    bool isCurrentlySelected = false,
  }) {
    // 기본 크기
    double baseSize = 60;

    // 현재 선택된 상태와 선택된 공인지에 따라 테두리 스타일 설정
    // null이 될 수 없도록 수정: BoxBorder 변수
    BoxBorder? border;
    if (isCurrentlySelected) {
      border = Border.all(color: AppColors.primary, width: 3);
    } else if (isSelected) {
      border = Border.all(color: Colors.amber, width: 3);
    }

    return Container(
      width: baseSize,
      height: baseSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
        boxShadow: [
          if (isSelected || isCurrentlySelected)
            BoxShadow(
              color:
                  isCurrentlySelected
                      ? AppColors.primary.withOpacity(0.5)
                      : Colors.amber.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap:
              _isSpinning
                  ? null
                  : () {
                    if (!_isSpinning && _selectedParticipantIndex == null) {
                      widget.onSelectParticipant(ball.participant.memberId);
                    }
                  },
          child: CircleAvatar(
            backgroundColor: AppColors.primary,
            backgroundImage:
                ball.participant.profileUrl != null
                    ? NetworkImage(ball.participant.profileUrl!)
                    : null,
            child:
                ball.participant.profileUrl == null
                    ? Text(
                      ball.participant.nickname.substring(0, 1),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _resultController.dispose();
    super.dispose();
  }
}

// 몰빵 공 클래스
class MolbbangBall {
  final int id;
  final ExpenseParticipant participant;
  Offset position;
  Offset velocity;
  final AnimationController controller;

  MolbbangBall({
    required this.id,
    required this.participant,
    Offset? initialPosition,
    Offset? initialVelocity,
    required this.controller,
  }) : position = initialPosition ?? Offset.zero,
       velocity = initialVelocity ?? Offset.zero {
    controller.addListener(_updatePosition);
  }

  void _updatePosition() {
    // 다음 위치 계산
    position += velocity;

    // 화면 경계에서 튕기기 (반사)
    double maxX = 200; // 실제 화면 너비에 맞게 수정
    double maxY = 150; // 실제 화면 높이에 맞게 수정

    double dx = position.dx;
    double dy = position.dy;
    double vx = velocity.dx;
    double vy = velocity.dy;

    if (dx <= 0 || dx >= maxX) vx *= -1;
    if (dy <= 0 || dy >= maxY) vy *= -1;

    position = Offset(dx.clamp(0, maxX), dy.clamp(0, maxY));
    velocity = Offset(vx, vy);
  }
}
