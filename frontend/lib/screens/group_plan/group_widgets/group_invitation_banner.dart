import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class GroupInvitationBanner extends StatelessWidget {
  final String groupName;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const GroupInvitationBanner({
    Key? key,
    required this.groupName,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.noticeMemoGreen.withOpacity(0.9),
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
              Icon(Icons.groups, color: AppColors.primaryDark, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '그룹 초대',
                  style: TextStyle(
                    fontFamily: 'Anemone',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDarkest,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"$groupName" 그룹에 초대되었습니다.',
            style: TextStyle(
              fontFamily: 'Anemone_air',
              fontSize: 16,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onDecline,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.mediumGray,
                ),
                child: const Text(
                  '거절',
                  style: TextStyle(
                    fontFamily: 'Anemone_air',
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  '참여하기',
                  style: TextStyle(
                    fontFamily: 'Anemone_air',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}