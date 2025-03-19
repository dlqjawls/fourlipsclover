import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/group_model.dart';
import '../../../providers/group_provider.dart';
import 'group_card.dart';

class GroupListView extends StatelessWidget {
  final List<Group> groups;
  final GroupProvider groupProvider;
  final VoidCallback onCreateGroup;

  const GroupListView({
    Key? key,
    required this.groups,
    required this.groupProvider,
    required this.onCreateGroup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '내 그룹',
                  style: TextStyle(
                    fontFamily: 'Anemone_air',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                GestureDetector(
                  onTap: onCreateGroup,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.verylightGray,
                      border: Border.all(
                        color: AppColors.lightGray,
                        width: 2.0,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        color: AppColors.mediumGray,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 그룹 그리드
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 한 줄에 두 개의 카드
                crossAxisSpacing: 16, // 가로 간격
                mainAxisSpacing: 16, // 세로 간격
                childAspectRatio: 1.0, // 카드 비율 조정
              ),
              itemCount: groups.length, // 그룹 수
              itemBuilder: (context, index) {
                final group = groups[index];
                final isSelected = groupProvider.selectedGroup?.groupId == group.groupId;
                
                return GroupCard(
                  group: group,
                  isSelected: isSelected,
                  onTap: () {
                    // 그룹 선택 및 상세 화면으로 이동
                    groupProvider.selectGroup(group.groupId);
                    // 여기에 그룹 상세 화면으로 이동하는 코드 추가
                    // Navigator.push(...);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}