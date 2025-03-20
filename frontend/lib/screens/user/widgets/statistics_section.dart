import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/user_model.dart';

class StatisticsSection extends StatelessWidget {
  final UserProfile profile;

  const StatisticsSection({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatItem(
              icon: Icons.edit_note, // 변경
              label: '작성한 글', // 변경
              value: '${profile.writtenPosts}개', // 변경
            ),
            const SizedBox(height: 12),
            _buildStatItem(
              icon: Icons.favorite, // 변경
              label: '받은 좋아요', // 변경
              value: '${profile.receivedLikes}개', // 변경
            ),
            const SizedBox(height: 12),
            _buildStatItem(
              icon: Icons.rate_review, // 변경
              label: '작성한 리뷰', // 변경
              value: '${profile.writtenReviews}개', // 변경
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: AppColors.darkGray)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
