import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/screens/user/user_edit.dart';
import 'package:frontend/screens/user/user_profile.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/providers/app_provider.dart';
import 'package:frontend/screens/auth/login_screen.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.logout();

      // 로그인 화면으로 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('로그아웃 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder:
          (context, userProvider, child) => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // 여기를 MyConsumptionPatternScreen으로 수정
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const MyConsumptionPatternScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.background,
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 2.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '나의 프로필',
                        style: TextStyle(color: AppColors.darkGray),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => UserEditScreen(
                                  profile: userProvider.userProfile!,
                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.background,
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 2.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            '나의 정보 수정',
                            style: TextStyle(color: AppColors.darkGray),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 12),
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: () => _handleLogout(context),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors.background,
              //       foregroundColor: AppColors.error,
              //       side: const BorderSide(color: AppColors.error, width: 2.0),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //     ),
              //     child: const Text(
              //       '로그아웃',
              //       style: TextStyle(color: AppColors.error),
              //     ),
              //   ),
              // ),
            ],
          ),
    );
  }
}
