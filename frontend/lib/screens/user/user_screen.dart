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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CloverProfileSection(profile: userProfile),
                const SizedBox(height: 24),
                StatisticsSection(profile: userProfile),
                const SizedBox(height: 16),
                const ActionButtons(),
                const SizedBox(height: 16),
                if (userProfile.planResponses.isNotEmpty)
                  PlanSection(plans: userProfile.planResponses),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserJourneyScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.eco, color: AppColors.primary, size: 24),
                            const SizedBox(width: 8),
                            const Text(
                              '진행중인 여정',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGray,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.mediumGray,
                              size: 16,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '현재 진행중인 여정을 확인해보세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TrustScoreIndicator(trustScore: userProfile.trustScore),
                const SizedBox(height: 16),
                PaymentHistory(payments: userProfile.recentPayments),
                if (userProfile.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  TagsSection(tags: userProfile.tags),
                ],
                const SizedBox(height: 32),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      try {
                        await context.read<AppProvider>().logout();
                        if (!mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('로그아웃 실패: $e')));
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
