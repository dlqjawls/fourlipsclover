import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/group/group_model.dart';

class GroupCard extends StatelessWidget {
  final Group group;
  final bool isSelected;
  final VoidCallback onTap;

  const GroupCard({
    Key? key,
    required this.group,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.white, // 카드 기본 배경색은 흰색으로
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border:
                isSelected
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 섹션 - 배경색 적용
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryLight, // 상단 배경색
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isSelected ? 10 : 12),
                    topRight: Radius.circular(isSelected ? 10 : 12),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.name,
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDarkest,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      group.isPublic ? Icons.lock_open : Icons.lock,
                      color: AppColors.primaryDarkest,
                      size: 18,
                    ),
                  ],
                ),
              ),

              // 하단 섹션
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 그룹 설명
                      Text(
                        group.description,
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 14,
                          color: AppColors.darkGray,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),

                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 날짜 포맷팅
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
