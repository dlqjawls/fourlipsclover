import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

class ProfileImageSection extends StatelessWidget {
  const ProfileImageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        CircleAvatar(
          radius: 80,
          backgroundColor: AppColors.lightGray,
          child: const Icon(
            Icons.person,
            size: 80,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
            ),
            onPressed: () {},
            child: const Text('프로필 사진 변경'),
          ),
        ),
      ],
    );
  }
}
