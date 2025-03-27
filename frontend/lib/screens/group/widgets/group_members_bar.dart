import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/group/group_detail_model.dart';
import '../../../models/group/member_model.dart';

class GroupMembersBar extends StatelessWidget {
  final VoidCallback onAddMember;
  final List<Member> members; // 그룹의 실제 멤버 목록
  final int currentUserId; // 현재 로그인한 사용자 ID

  const GroupMembersBar({
    Key? key,
    required this.onAddMember,
    required this.members,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 멤버가 없는 경우 빈 상태 처리
    if (members.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '아직 그룹 멤버가 없습니다',
            style: TextStyle(
              fontFamily: 'Anemone_air',
              fontSize: 14,
              color: AppColors.mediumGray,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            '그룹 멤버',
            style: TextStyle(
              fontFamily: 'Anemone_air',
              fontSize: 12,
              color: AppColors.mediumGray,
            ),
          ),

          const SizedBox(height: 8),

          // 멤버 아바타 목록 (수평 스크롤)
          SizedBox(
            height: 70,
            child: Row(
              children: [
                // 멤버 리스트 (스크롤 가능)
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // 그룹장, 일만 멤버 표시시
                      // 그룹장 먼저 표시
                      ...members
                          .where((m) => m.role == '그룹장' || m.role == 'OWNER')
                          .map(
                            (member) => Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: _buildMemberAvatar(member),
                            ),
                          ),
                      // 일반 멤버 표시
                      ...members
                          .where((m) => m.role != '그룹장' && m.role != 'OWNER')
                          .map(
                            (member) => Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: _buildMemberAvatar(member),
                            ),
                          ),

                      // 공간 추가하여 초대 버튼과 겹치지 않게
                      const SizedBox(width: 8),
                    ],
                  ),
                ),

                // 멤버 추가 버튼
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: onAddMember,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.verylightGray,
                            border: Border.all(
                              color: AppColors.lightGray,
                              width: 1.0,
                            ),
                          ),
                          child: Icon(
                            Icons.person_add,
                            color: AppColors.mediumGray,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '초대하기',
                          style: TextStyle(
                            fontFamily: 'Anemone_air',
                            fontSize: 11,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 멤버 아바타 위젯
  Widget _buildMemberAvatar(Member member) {
    Color roleColor;
    String roleText = '';

    // 역할에 따른 테두리 색상과 라벨 결정
    switch (member.role.toUpperCase()) {
      case '그룹장':
      case 'OWNER':
        roleColor = AppColors.primaryDarkest;
        roleText = '그룹장';
        break;
      default:
        roleColor = AppColors.primary;
        roleText = ''; // 일반 멤버는 라벨 없음
    }

    // 현재 로그인한 사용자인지 확인
    bool isCurrentUser = member.memberId == currentUserId;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 프로필 이미지와 역할 배지
        Stack(
          children: [
            // 프로필 이미지
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: roleColor, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(23),
                child:
                    member.profileUrl != null && member.profileUrl!.isNotEmpty
                        ? Image.network(member.profileUrl!, fit: BoxFit.cover)
                        : CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            member.nickname.isNotEmpty
                                ? member.nickname[0]
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
              ),
            ),

            // 역할 배지 (그룹장과 총무만)
            if (roleText.isNotEmpty)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Text(
                    roleText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),

        // 이름
        const SizedBox(height: 4),
        SizedBox(
          width: 46,
          child: Text(
            isCurrentUser ? '나' : member.nickname, // 현재 사용자는 '나'로 표시
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Anemone_air',
              fontSize: 11,
              color: AppColors.darkGray,
              fontWeight:
                  isCurrentUser
                      ? FontWeight.bold
                      : FontWeight.normal, // 현재 사용자 강조
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
