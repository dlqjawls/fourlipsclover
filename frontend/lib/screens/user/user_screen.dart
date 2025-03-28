import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'widgets/cloverprofilesection.dart';
import 'widgets/statistics_section.dart';
import 'widgets/action_buttons.dart';
import 'widgets/Luckeyindicator.dart';
import 'widgets/current_journey_section.dart';
import 'widgets/payment_history.dart';
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
      debugPrint('유저 ID: ${userProfile?.userId}');
      debugPrint('ID: ${userProfile?.userId}');
      debugPrint('이름: ${userProfile?.name}');
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
                LuckGaugeIndicator(luckGauge: userProfile.luckGauge),
                const SizedBox(height: 16),
                if (userProfile.currentJourney != null)
                  CurrentJourneySection(journey: userProfile.currentJourney!),
                const SizedBox(height: 16),
                PaymentHistory(payments: userProfile.recentPayments),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
