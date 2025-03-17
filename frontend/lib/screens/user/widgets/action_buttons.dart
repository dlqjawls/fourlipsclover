import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/config/routes.dart';
import 'package:frontend/screens/user/user_edit.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                 MaterialPageRoute(builder: (context) => const UserEditScreen()),
              )
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 2.0),
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
                // pushReplacement 대신 push 사용
                context,
                MaterialPageRoute(builder: (context) => const UserEditScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 2.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('나의 정보 수정', style: TextStyle(color: AppColors.darkGray)),
                SizedBox(width: 8),
                Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
