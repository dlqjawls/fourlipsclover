import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/group/group_model.dart';
import '../../../providers/group_provider.dart';
import 'group_card.dart';

class GroupListView extends StatefulWidget {
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
  State<GroupListView> createState() => _GroupListViewState();
}

class _GroupListViewState extends State<GroupListView> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 컴포넌트가 처음 생성될 때 모든 그룹의 상세 정보를 미리 로드
    _preloadGroupDetails();
  }

  Future<void> _preloadGroupDetails() async {
    // 각 그룹의 상세 정보를 미리 로드
    for (final group in widget.groups) {
      await widget.groupProvider.fetchGroupDetail(group.groupId);
    }

    // 로딩 완료 후 화면 갱신
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (기존 코드와 동일)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              children: [
                Center(
                  child: Text(
                    '내 그룹',
                    style: TextStyle(
                      fontFamily: 'Anemone_air',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: widget.onCreateGroup,
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
                ),
              ],
            ),
          ),

          // 그룹 그리드
          Expanded(
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator()) // 로딩 중 표시
                    : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                      itemCount: widget.groups.length,
                      itemBuilder: (context, index) {
                        final group = widget.groups[index];
                        final isSelected =
                            widget.groupProvider.selectedGroup?.groupId ==
                            group.groupId;

                        // 그룹장 닉네임과 멤버 수 가져오기
                        final ownerName = widget.groupProvider.getOwnerNickname(
                          group.groupId,
                        );
                        final memberCount = widget.groupProvider.getMemberCount(
                          group.groupId,
                        );

                        return GroupCard(
                          group: group,
                          isSelected: isSelected,
                          ownerName: ownerName,
                          memberCount: memberCount,
                          onTap: () async {
                            // 그룹 선택
                            widget.groupProvider.selectGroup(group.groupId);

                            // 그룹 상세 정보는 이미 로드되었으므로 바로 가져옴
                            final groupDetail = widget.groupProvider
                                .getGroupDetail(group.groupId);

                            if (groupDetail != null) {
                              // 그룹 상세 화면으로 이동
                              if (context.mounted) {
                                Navigator.pushNamed(
                                  context,
                                  '/group_detail',
                                  arguments: {
                                    'groupDetail': groupDetail,
                                    'group': group,
                                  },
                                );
                              }
                            } else {
                              // 혹시라도 상세 정보가 없는 경우 다시 로드
                              final fetchedDetail = await widget.groupProvider
                                  .fetchGroupDetail(group.groupId);

                              if (fetchedDetail != null && context.mounted) {
                                Navigator.pushNamed(
                                  context,
                                  '/group_detail',
                                  arguments: {
                                    'groupDetail': fetchedDetail,
                                    'group': group,
                                  },
                                );
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '그룹 정보를 불러오는데 실패했습니다.',
                                      style: TextStyle(
                                        fontFamily: 'Anemone_air',
                                      ),
                                    ),
                                    backgroundColor: AppColors.red,
                                  ),
                                );
                              }
                            }
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
