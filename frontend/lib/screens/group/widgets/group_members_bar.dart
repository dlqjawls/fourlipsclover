import 'package:flutter/material.dart';
import '../../../config/theme.dart';

// 그룹 멤버 클래스 (내부 사용)
class _GroupMember {
  final String id;
  final String name;
  final String? profileImage;
  final String role; // '그룹장', '총무', '멤버' 등

  _GroupMember({
    required this.id,
    required this.name,
    this.profileImage,
    required this.role,
  });
}

class GroupMembersBar extends StatelessWidget {
  final VoidCallback onAddMember;

  const GroupMembersBar({Key? key, required this.onAddMember})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 내부 더미 데이터
    final members = [
      _GroupMember(id: '1', name: '김그룹장', role: '그룹장'),
      _GroupMember(id: '2', name: '이총무', role: '총무'),
      _GroupMember(id: '3', name: '박여행', role: '멤버'),
      _GroupMember(id: '4', name: '최계획', role: '멤버'),
      _GroupMember(id: '5', name: '정친구', role: '멤버'),
      _GroupMember(id: '6', name: '정친구', role: '멤버'),
      _GroupMember(id: '7', name: '정친구', role: '멤버'),
      _GroupMember(id: '8', name: '정친구', role: '멤버'),
      _GroupMember(id: '9', name: '정친구', role: '멤버'),
    ];

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
                      // 그룹장과 총무를 맨 앞에 배치
                      ...members
                          .where((m) => m.role == '그룹장')
                          .map(
                            (member) => Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: _buildMemberAvatar(member),
                            ),
                          ),
                      ...members
                          .where((m) => m.role == '총무')
                          .map(
                            (member) => Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: _buildMemberAvatar(member),
                            ),
                          ),
                      ...members
                          .where((m) => m.role != '그룹장' && m.role != '총무')
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
  Widget _buildMemberAvatar(_GroupMember member) {
    Color roleColor;
    String roleText = '';

    // 역할에 따른 테두리 색상과 라벨 결정
    switch (member.role) {
      case '그룹장':
        roleColor = AppColors.primaryDarkest;
        roleText = '그룹장';
        break;
      case '총무':
        roleColor = AppColors.orange;
        roleText = '총무';
        break;
      default:
        roleColor = AppColors.primary;
    }

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
                    member.profileImage != null
                        ? Image.network(member.profileImage!, fit: BoxFit.cover)
                        : CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            member.name.isNotEmpty ? member.name[0] : '?',
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
            member.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Anemone_air',
              fontSize: 11,
              color: AppColors.darkGray,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
