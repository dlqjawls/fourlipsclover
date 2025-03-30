import 'package:flutter/material.dart';
import '../../../models/group/member_model.dart';
import '../../../config/theme.dart';

class TrainSeatMemberSelection extends StatelessWidget {
  final List<Member> members;
  final Set<int> selectedMemberIds;
  final int? currentUserId;
  final Function(int, bool) onMemberSelected;

  const TrainSeatMemberSelection({
    Key? key,
    required this.members,
    required this.selectedMemberIds,
    required this.currentUserId,
    required this.onMemberSelected,
  }) : super(key: key);

  // 좌석 배치 방식 (KTX 스타일: 2-2)
  List<List<Member?>> _arrangeSeats() {
    final arrangedSeats = <List<Member?>>[];
    final totalMembers = members.length;

    // 한 줄에 좌석 수 (KTX 스타일: 2-2)
    int seatsPerRow = 4;
    int row = 0;

    while (row * seatsPerRow < totalMembers) {
      final rowSeats = <Member?>[];

      for (int i = 0; i < seatsPerRow; i++) {
        final index = row * seatsPerRow + i;
        if (index < totalMembers) {
          rowSeats.add(members[index]);
        } else {
          // 남은 좌석은 null로 채움
          rowSeats.add(null);
        }
      }

      arrangedSeats.add(rowSeats);
      row++;
    }

    return arrangedSeats;
  }

  @override
  Widget build(BuildContext context) {
    final arrangedSeats = _arrangeSeats();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 좌석 선택 안내
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '여행에 참여할 멤버를 선택해주세요',
              style: TextStyle(
                fontFamily: 'Anemone_air',
                fontSize: 16,
                color: AppColors.mediumGray,
              ),
            ),
          ),

          // KTX 열차 컨테이너
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 열차 헤더
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.train, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        '208 호차',
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 좌석 번호 레이블
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'A',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.mediumGray,
                              ),
                            ),
                            Text(
                              'B',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20), // 통로
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'C',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.mediumGray,
                              ),
                            ),
                            Text(
                              'D',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 좌석 배치
                ...List.generate(arrangedSeats.length, (index) {
                  return _buildSeatRow(arrangedSeats[index], index + 1);
                }),

                const SizedBox(height: 16),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 범례
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(AppColors.primary, '선택됨'),
                const SizedBox(width: 16),
                _buildLegendItem(AppColors.background, '미선택'),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 한 줄의 좌석을 생성하는 메서드
  Widget _buildSeatRow(List<Member?> rowSeats, int rowNumber) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 줄 번호
          SizedBox(
            width: 24,
            child: Text(
              '$rowNumber',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Anemone_air',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.mediumGray,
              ),
            ),
          ),

          // 왼쪽 좌석 (A, B)
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildKtxSeat(rowSeats[0], 'A'),
                _buildKtxSeat(rowSeats[1], 'B'),
              ],
            ),
          ),

          // 통로
          Container(
            width: 20,
            height: 60,
            alignment: Alignment.center,
            child: Container(width: 1, height: 40, color: Colors.grey[300]),
          ),

          // 오른쪽 좌석 (C, D)
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildKtxSeat(rowSeats[2], 'C'),
                _buildKtxSeat(rowSeats[3], 'D'),
              ],
            ),
          ),

          const SizedBox(width: 24), // 오른쪽 여백 (좌석번호 좌측 여백과 균형 맞추기)
        ],
      ),
    );
  }

  // KTX 스타일 좌석 위젯
  Widget _buildKtxSeat(Member? member, String seatCode) {
    if (member == null) {
      // 빈 좌석
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[300]!),
        ),
      );
    }

    final isCurrentUser = member.memberId == currentUserId;
    final isSelected = selectedMemberIds.contains(member.memberId);

    return GestureDetector(
      onTap:
          isCurrentUser
              ? null // 현재 사용자는 선택 불가
              : () {
                onMemberSelected(member.memberId, !isSelected);
              },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color:
              isCurrentUser
                  ? AppColors.primary.withOpacity(0.3)
                  : (isSelected ? AppColors.primary : Colors.white),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.primary.withOpacity(0.8)
                    : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 사용자 아이콘
            Icon(
              Icons.person,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 16,
            ),

            // 이름
            Text(
              member.nickname,
              style: TextStyle(
                fontFamily: 'Anemone_air',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),

            // 현재 사용자 표시
            if (isCurrentUser)
              const Text(
                '(나)',
                style: TextStyle(
                  fontFamily: 'Anemone_air',
                  fontSize: 8,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  // 범례 아이템
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[300]!),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Anemone_air',
            fontSize: 12,
            color: AppColors.darkGray,
          ),
        ),
      ],
    );
  }
}
