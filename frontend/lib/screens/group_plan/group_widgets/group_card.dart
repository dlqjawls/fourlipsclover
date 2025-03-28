import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/group/group_model.dart';

class GroupCard extends StatelessWidget {
  final Group group;
  final bool isSelected;
  final VoidCallback onTap;
  // 추가로 받을 데이터
  final int? memberCount;
  final String? ownerName; // 그룹장 이름 (옵션)

  const GroupCard({
    Key? key,
    required this.group,
    required this.isSelected,
    required this.onTap,
    this.memberCount,
    this.ownerName,
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
                      // 인원수 정보 (첫 번째로 표시)
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 14,
                            color: AppColors.darkGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            memberCount != null
                                ? '인원: $memberCount명'
                                : '인원: 1명',
                            style: TextStyle(
                              fontFamily: 'Anemone_air',
                              fontSize: 12,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // 그룹장 정보 (두 번째로 표시)
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: AppColors.darkGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ownerName != null ? '그룹장: $ownerName' : '그룹장',
                            style: TextStyle(
                              fontFamily: 'Anemone_air',
                              fontSize: 12,
                              color: AppColors.darkGray,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // 그룹 설명 정보 (세 번째로 표시)
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: AppColors.darkGray,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              group.description.isNotEmpty
                                  ? '설명: ${group.description}'
                                  : '그룹 설명 없음',
                              style: TextStyle(
                                fontFamily: 'Anemone_air',
                                fontSize: 12,
                                color: AppColors.darkGray,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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
}
