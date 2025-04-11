import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import '../../../../models/user_model.dart';

class StatisticsSection extends StatelessWidget {
  final UserProfile profile;

  const StatisticsSection({super.key, required this.profile});

  Widget _buildLevelIcon(dynamic rank) {
    int level;
    if (rank is num) {
      level = rank.toInt();
    } else if (rank is String) {
      // 숫자 형태의 문자열인 경우
      if (int.tryParse(rank) != null) {
        level = int.parse(rank);
      }
      // ONE, TWO, THREE, FOUR 형태의 문자열인 경우
      else {
        switch (rank.toUpperCase()) {
          case 'ONE':
            level = 1;
            break;
          case 'TWO':
            level = 2;
            break;
          case 'THREE':
            level = 3;
            break;
          case 'FOUR':
            level = 4;
            break;
          default:
            level = 1;
        }
      }
    } else {
      level = 1;
    }

    // 레벨 범위 제한 (1-4)
    level = level.clamp(1, 4);

    String levelImage;
    switch (level) {
      case 1:
        levelImage = 'assets/images/level1.png';
        break;
      case 2:
        levelImage = 'assets/images/level2.png';
        break;
      case 3:
        levelImage = 'assets/images/level3.png';
        break;
      case 4:
        levelImage = 'assets/images/level4.png';
        break;
      default:
        levelImage = 'assets/images/level1.png';
    }
    return Image.asset(
      levelImage,
      width: 24,
      height: 24,
      color: AppColors.primary,
    );
  }

  String _formatRankDisplay(dynamic rank) {
    if (rank is num) {
      return 'Lv.${rank.toInt()}';
    } else if (rank is String) {
      // 숫자 형태의 문자열인 경우
      if (int.tryParse(rank) != null) {
        return 'Lv.$rank';
      }
      // ONE, TWO, THREE, FOUR 형태의 문자열인 경우
      else {
        switch (rank.toUpperCase()) {
          case 'ONE':
            return 'Lv.1';
          case 'TWO':
            return 'Lv.2';
          case 'THREE':
            return 'Lv.3';
          case 'FOUR':
            return 'Lv.4';
          default:
            return 'Lv.1';
        }
      }
    } else {
      return 'Lv.1';
    }
  }

  Widget _buildStatItem(
    String label,
    String? value,
    IconData icon, {
    bool isRank = false,
  }) {
    return Column(
      children: [
        isRank
            ? _buildLevelIcon(value)
            : Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          isRank ? _formatRankDisplay(value) : (value ?? '미정'),
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
          _buildStatItem(
            '지역 랭크',
            profile.localRank.toString(),
            Icons.place,
            isRank: true,
          ),
          _buildStatItem('그룹', profile.groupCount.toString(), Icons.group),
        ],
      ),
    );
  }
}
