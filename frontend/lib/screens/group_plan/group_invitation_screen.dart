// lib/screens/group_plan/group_invitation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../models/group/member_model.dart';
import '../../providers/group_provider.dart';
import '../../widgets/clover_loading_spinner.dart';
import 'dart:math' as math;
import '../../widgets/toast_bar.dart';
import 'group_widgets/invitation/envelope_widget.dart';
import 'group_widgets/invitation/invitation_content_widget.dart';

class GroupInvitationScreen extends StatefulWidget {
  final String token;

  const GroupInvitationScreen({Key? key, required this.token})
    : super(key: key);

  @override
  State<GroupInvitationScreen> createState() => _GroupInvitationScreenState();
}

class _GroupInvitationScreenState extends State<GroupInvitationScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _invitationInfo;

  // 봉투 애니메이션 관련 변수
  late AnimationController _animationController;
  late Animation<double> _flapAnimation;
  late Animation<double> _letterAnimation;
  late Animation<double> _letterRiseAnimation;
  late Animation<double> _sparkleAnimation; // 반짝임 효과 애니메이션 추가
  bool _isEnvelopeOpen = false;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800), // 조금 더 길게 설정
    );

    // 봉투 뚜껑 애니메이션 - 곡선 조정
    _flapAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.0,
          0.4,
          curve: Curves.easeOutBack,
        ), // easeOutBack으로 변경
      ),
    );

    // 편지 내용물 나타나는 애니메이션 - 곡선 조정
    _letterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.4,
          0.7,
          curve: Curves.easeOutCubic,
        ), // easeOutCubic으로 변경
      ),
    );

    // 편지가 위로 올라가는 애니메이션 - 곡선 조정
    _letterRiseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.7,
          1.0,
          curve: Curves.elasticOut,
        ), // elasticOut으로 변경
      ),
    );

    // 반짝임 효과 애니메이션 추가
    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeInOut),
      ),
    );

    // 애니메이션 리스너
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isEnvelopeOpen = true;
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _isEnvelopeOpen = false;
        });
      }
    });

    // 토큰 저장 및 초대 정보 로드
    _saveTokenForLater();
    _loadInvitationInfo();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 봉투 열기 애니메이션
  void _openEnvelope() {
    if (!_isEnvelopeOpen) {
      _animationController.forward();
    }
  }

  // 토큰 저장 (나중에 처리할 수 있도록)
  Future<void> _saveTokenForLater() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pendingInvitationToken', widget.token);
      debugPrint('초대 토큰 저장됨: ${widget.token}');
    } catch (e) {
      debugPrint('초대 토큰 저장 실패: $e');
    }
  }

  // 초대 정보 로드
  Future<void> _loadInvitationInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint('초대 정보 로드 시작 - 토큰: ${widget.token}');
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final result = await groupProvider.checkInvitationLink(widget.token);

      if (mounted) {
        if (result != null) {
          // 결과에서 GroupInvitation 객체 추출
          final groupInvitation = result['groupInvitation'];

          if (groupInvitation != null) {
            // GroupId 추출
            final groupId = groupInvitation['groupId'];

            try {
              // 그룹 ID로 그룹 상세 정보 가져오기
              final groupDetail = await groupProvider.fetchGroupDetail(groupId);

              setState(() {
                // 새로운 형식으로 _invitationInfo 구성
                _invitationInfo = {
                  'groupName': groupDetail?.name ?? '알 수 없는 그룹',
                  'description': groupDetail?.description ?? '',
                  'isPublic': groupDetail?.isPublic ?? false,
                  'memberCount': groupDetail?.members.length ?? 0,
                  'ownerName': _findOwnerName(groupDetail?.members) ?? '알 수 없음',
                  'groupInvitation': groupInvitation,
                };
                _isLoading = false;
              });
            } catch (e) {
              // 기본 정보만 설정
              setState(() {
                _invitationInfo = {
                  'groupId': groupId,
                  'groupName': '초대된 그룹', // 기본값 설정
                  'description': '그룹에 참여하시겠습니까?', // 기본값 설정
                  'isPublic': true, // 기본값 설정
                  'memberCount': 0, // 기본값 설정
                  'ownerName': '그룹 관리자', // 기본값 설정
                  'groupInvitation': groupInvitation,
                };
                _isLoading = false;
              });
            }
          } else {
            setState(() {
              _error = '초대 정보 형식이 올바르지 않습니다.';
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _error = '초대 정보를 불러올 수 없습니다. 초대가 만료되었거나 유효하지 않습니다.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('초대 정보 로드 오류: $e');
      if (mounted) {
        setState(() {
          _error = '초대 정보를 불러올 수 없습니다: $e';
          _isLoading = false;
        });
      }
    }
  }

  // 그룹 멤버 중 OWNER 역할을 가진 멤버의 이름 찾기
  String? _findOwnerName(List<Member>? members) {
    if (members == null) return null;

    for (var member in members) {
      if (member.role == 'OWNER') {
        return member.nickname;
      }
    }
    return members.isNotEmpty ? members.first.nickname : null;
  }

  // 그룹 가입 요청
  Future<void> _joinGroup() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      debugPrint('그룹 가입 요청 시작 - 토큰: ${widget.token}');
      final success = await groupProvider.joinGroup(widget.token);

      if (mounted) {
        if (success) {
          // 토큰 삭제 (이미 처리됨)
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('pendingInvitationToken');

          // 성공 메시지 표시
          ToastBar.clover('그룹 가입 요청 완료');

          // 그룹 목록 새로고침
          await groupProvider.fetchMyGroups();

          // 그룹 화면으로 이동 (홈 화면이 아닌)
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/group',
            (route) => false,
            arguments: {'initialTab': 2}, // 그룹 탭으로 이동 (탭 인덱스에 맞게 조정)
          );
        } else {
          setState(() {
            _error = '그룹 가입 요청에 실패했습니다: ${groupProvider.error}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('그룹 가입 요청 오류: $e');
      if (mounted) {
        setState(() {
          _error = '그룹 가입 요청 중 오류가 발생했습니다: $e';
          _isLoading = false;
        });
      }
    }
  }

  // 나중에 처리하기
  Future<void> _postponeDecision() async {
    // 토큰은 이미 저장되어 있으므로 그룹 화면으로 이동
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/group',
      (route) => false,
      arguments: {'initialTab': 2}, // 그룹 탭으로 이동 (탭 인덱스에 맞게 조정)
    );
  }

  // 초대 거절
  Future<void> _declineInvitation() async {
    // 토큰 삭제
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pendingInvitationToken');

    // 그룹 화면으로 이동
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/group',
      (route) => false,
      arguments: {'initialTab': 2}, // 그룹 탭으로 이동 (탭 인덱스에 맞게 조정)
    );

    // 사용자에게 피드백 제공
ToastBar.clover('그룹 초대를 거절 했습니다.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 그라데이션 배경 추가
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppColors.verylightGray.withOpacity(0.3)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // 앱바 대체 커스텀 헤더
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildCustomHeader(),
              ),
              // 메인 콘텐츠
              LoadingOverlay(
                isLoading: _isLoading,
                child: Padding(
                  padding: const EdgeInsets.only(top: 60), // 헤더 높이만큼 패딩
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 커스텀 헤더 위젯
  Widget _buildCustomHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // 뒤로가기 버튼
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          // 제목
          Text(
            '그룹 초대',
            style: TextStyle(
              color: AppColors.darkGray,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontFamily: 'Anemone_air',
            ),
          ),
          const Spacer(),
          // 우측 공간 균형을 위한 투명 아이콘
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return _buildErrorState();
    }

    if (_invitationInfo == null) {
      return _buildLoadingState();
    }

    // 봉투 및 초대장 UI 반환
    return Stack(
      children: [
        // 배경 장식 요소 추가
        _buildBackgroundDecoration(),

        // 봉투는 항상 하단에 배치
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 봉투 위젯
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return EnvelopeWidget(
                      flapAnimation: _flapAnimation,
                      letterAnimation: _letterAnimation,
                      sparkleAnimation: _sparkleAnimation,
                      isEnvelopeOpen: _isEnvelopeOpen,
                      onTap: _openEnvelope,
                    );
                  },
                ),

                // 봉투 아래 문구 추가
                const SizedBox(height: 40),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _animationController.value < 0.1 ? 1.0 : 0.0,
                  child: Column(
                    children: [
                      Text(
                        '📬 초대장이 도착했어요!',
                        style: TextStyle(
                          color: AppColors.darkGray,
                          fontSize: 19,
                          fontFamily: 'Anemone_air',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        '친구들과의 특별한 여행이 곧 시작돼요',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontFamily: 'Anemone_air',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 초대장 내용 - 봉투 위에 올라옴
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            // 초대장이 위로 올라오는 애니메이션
            return _letterAnimation.value > 0
                ? Opacity(
                  opacity: _letterAnimation.value,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top:
                            MediaQuery.of(context).size.height * 0.12 -
                            (_letterRiseAnimation.value * 50),
                        left: 16,
                        right: 16,
                        bottom:
                            MediaQuery.of(context).size.height *
                            0.35, // 봉투를 가리지 않도록 충분한 하단 패딩
                      ),
                      child: InvitationContentWidget(
                        invitationInfo: _invitationInfo!,
                        onJoin: _joinGroup,
                        onPostpone: _postponeDecision,
                        onDecline: _declineInvitation,
                      ),
                    ),
                  ),
                )
                : Container();
          },
        ),
      ],
    );
  }

  // 배경 장식 요소
  Widget _buildBackgroundDecoration() {
    return IgnorePointer(
      child: Stack(
        children: [
          // 상단 왼쪽 클로버 장식
          Positioned(
            top: 10,
            left: -20,
            child: Opacity(
              opacity: 0.1,
              child: Transform.rotate(
                angle: -0.3,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 80,
                  height: 80,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          // 하단 오른쪽 클로버 장식
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15,
            right: -30,
            child: Opacity(
              opacity: 0.08,
              child: Transform.rotate(
                angle: 0.5,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          // 중앙 패턴
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/logo.png'),
                    repeat: ImageRepeat.repeat,
                    scale: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 에러 상태 UI
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline, color: Colors.red, size: 60),
          ),
          const SizedBox(height: 20),
          Text(
            '오류가 발생했습니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Anemone',
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontFamily: 'Anemone_air',
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _loadInvitationInfo,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/home', (route) => false);
                },
                icon: const Icon(Icons.home),
                label: const Text('홈으로 이동'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.darkGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 로딩 상태 UI
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 로딩 인디케이터 - 기본 원형 대신 클로버 로고 회전
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 2 * math.pi),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 48,
                  height: 48,
                  color: AppColors.primary,
                ),
              );
            },
            onEnd: () => setState(() {}), // 애니메이션 재시작
          ),
          const SizedBox(height: 20),
          Text(
            '초대 정보를 불러오는 중입니다...',
            style: TextStyle(
              fontFamily: 'Anemone_air',
              fontSize: 16,
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}
