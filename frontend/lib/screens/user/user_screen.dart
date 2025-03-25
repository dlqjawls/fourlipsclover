import 'package:flutter/material.dart';
import 'widgets/cloverprofilesection.dart';
import 'widgets/statistics_section.dart';
import 'widgets/action_buttons.dart';
import 'widgets/Luckeyindicator.dart';
import 'widgets/current_journey_section.dart';
import 'widgets/payment_history.dart';
import '../../config/theme.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final UserService _userService = UserService();
  UserProfile? _userProfile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _userService.getUserProfile('1231414142');
      setState(() => _userProfile = profile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필 로딩 실패')),
        );
      }
      print('Error loading user profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userProfile == null) {
      return const Scaffold(
        body: Center(child: Text('사용자 정보를 불러올 수 없습니다.')),
      );
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
                // 프로필 섹션 (이름, 닉네임, 프로필 이미지, 뱃지)
                CloverProfileSection(profile: _userProfile!),
                const SizedBox(height: 24),
                
                // 통계 섹션 (앨범 수, 그룹 수, 리뷰 수)
                StatisticsSection(profile: _userProfile!),
                const SizedBox(height: 16),
                
                // 액션 버튼들
                const ActionButtons(),
                const SizedBox(height: 16),
                
                // 행운 게이지 표시
                LuckGaugeIndicator(luckGauge: _userProfile!.luckGauge),
                const SizedBox(height: 16),
                
                // 현재 여정이 있는 경우 표시
                if (_userProfile!.currentJourney != null)
                  CurrentJourneySection(journey: _userProfile!.currentJourney!),
                const SizedBox(height: 16),
                
                // 최근 결제 내역
                PaymentHistory(payments: _userProfile!.recentPayments),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
