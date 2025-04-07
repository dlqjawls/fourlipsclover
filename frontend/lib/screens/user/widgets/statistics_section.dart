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

  Widget _buildStatItem(String label, String? value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ${value ?? '미정'}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
