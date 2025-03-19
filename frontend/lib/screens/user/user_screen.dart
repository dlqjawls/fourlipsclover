import 'package:flutter/material.dart';
import 'widgets/cloverprofilesection.dart';
import 'widgets/statistics_section.dart';
import 'widgets/action_buttons.dart';
import 'widgets/ProgressIndicator.dart';
import 'widgets/current_journey_section.dart';
import 'widgets/payment_history.dart';
import '../../config/theme.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verylightGray,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                // 클로버 프로필 섹션
                CloverProfileSection(),

                SizedBox(height: 24),

                // 통계 섹션
                StatisticsSection(),

                SizedBox(height: 16),

                // 액션 버튼들
                ActionButtons(),

                SizedBox(height: 16),

                // 진행 상태 표시
                ProgressIndicatorSection(),

                SizedBox(height: 16),

                // 현재 진행중인 여행
                CurrentJourneySection(),

                SizedBox(height: 16),

                // 결제 내역
                PaymentHistory(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
