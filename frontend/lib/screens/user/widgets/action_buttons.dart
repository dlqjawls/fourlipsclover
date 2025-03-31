import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/screens/user/user_edit.dart';
import 'package:frontend/screens/user/user_profile.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/user_provider.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder:
          (context, userProvider, child) => Row(
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
    );
  }
}
