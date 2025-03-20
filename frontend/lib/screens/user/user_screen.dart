import 'package:flutter/material.dart';
import 'widgets/cloverprofilesection.dart';
import 'widgets/statistics_section.dart';
import 'widgets/action_buttons.dart';
import 'widgets/ProgressIndicator.dart';
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
      final profile = await _userService.getUserProfile('user123');
      setState(() => _userProfile = profile);
    } catch (e) {
      // TODO: 에러 처리
      print('Error loading user profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userProfile == null) {
      return const Center(child: Text('사용자 정보를 불러올 수 없습니다.'));
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
                CloverProfileSection(profile: _userProfile!),
                const SizedBox(height: 24),
                StatisticsSection(profile: _userProfile!),
                const SizedBox(height: 16),
                const ActionButtons(),
                const SizedBox(height: 16),
                CloverScoreIndicator(cloverCount: _userProfile!.cloverCount),
                const SizedBox(height: 16),
                if (_userProfile!.currentJourney != null)
                  CurrentJourneySection(journey: _userProfile!.currentJourney!),
                const SizedBox(height: 16),
                const PaymentHistory(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
