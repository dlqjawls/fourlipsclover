import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/app_provider.dart';
import 'widgets/cloverprofilesection.dart';
import 'widgets/statistics_section.dart';
import 'widgets/action_buttons.dart';
import 'widgets/trust_score_indicator.dart';
import 'widgets/plan_section.dart';
import 'widgets/payment_history.dart';
import 'widgets/tags_section.dart';
import 'user_journey.dart';
import '../../config/theme.dart';
import '../../widgets/toast_bar.dart';
// import '../../models/user_model.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  void initState() {
    super.initState();
    // 초기 로드 시 유저 정보 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfile = context.read<UserProvider>().userProfile;
      debugPrint('초기 유저 정보 로드: ${userProfile?.toJson()}');
      debugPrint('멤버 ID: ${userProfile?.memberId}');
      debugPrint('닉네임: ${userProfile?.nickname}');
      debugPrint('이메일: ${userProfile?.email}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserProvider>().userProfile;

    if (userProfile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.verylightGray,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 프로필 섹션
                CloverProfileSection(profile: userProfile),
                const SizedBox(height: 16),

                // 통계 섹션
                StatisticsSection(profile: userProfile),
                const SizedBox(height: 16),

                // 프로필 버튼
                const ActionButtons(),
                const SizedBox(height: 16),

                // 신뢰도 점수
                TrustScoreIndicator(trustScore: userProfile.trustScore),
                const SizedBox(height: 16),

                // 내 태그
                if (userProfile.tags.isNotEmpty)
                  TagsSection(tags: userProfile.tags),
                const SizedBox(height: 16),

                // 결제 내역
                PaymentHistory(payments: userProfile.recentPayments),
                const SizedBox(height: 16),

                // 내 계획
                if (userProfile.planResponses.isNotEmpty)
                  PlanSection(plans: userProfile.planResponses),
                const SizedBox(height: 24),

                // 로그아웃 버튼
                Center(
                  child: TextButton(
                    onPressed: () async {
                      // 로그아웃 확인 다이얼로그 표시
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('로그아웃'),
                              content: const Text('정말 로그아웃 하시겠습니까?'),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('로그아웃'),
                                ),
                              ],
                            ),
                      );

                      if (shouldLogout != true) return;

                      try {
                        // 로딩 인디케이터 표시
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder:
                              (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                        );

                        await context.read<AppProvider>().logout();

                        if (!mounted) return;

                        // 로딩 다이얼로그 닫기
                        Navigator.pop(context);

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      } catch (e) {
                        if (!mounted) return;

                        // 로딩 다이얼로그 닫기
                        Navigator.pop(context);

                        ToastBar.clover('로그아웃 실패');
                      }
                    },
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(
                        color: AppColors.mediumGray,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
