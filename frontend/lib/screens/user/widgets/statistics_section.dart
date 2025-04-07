import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import '../../../../models/user_model.dart';

class StatisticsSection extends StatelessWidget {
  final UserProfile profile;

  const StatisticsSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            '리뷰',
            profile.reviewCount.toString(),
            Icons.rate_review,
          ),
          _buildStatItem('그룹', profile.groupCount.toString(), Icons.group),
          _buildStatItem('지역 랭크', profile.localRank, Icons.place),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
        ),
      ],
    );
  }
}
