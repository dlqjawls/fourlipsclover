// lib/screens/group/bottomsheet/join_request_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/group/group_join_request_model.dart';
import '../../../providers/group_provider.dart';
import '../../../widgets/clover_loading_spinner.dart';

class JoinRequestBottomSheet extends StatefulWidget {
  final int groupId;
  final List<GroupJoinRequest> requests;
  final VoidCallback onRequestProcessed;

  const JoinRequestBottomSheet({
    Key? key,
    required this.groupId,
    required this.requests,
    required this.onRequestProcessed,
  }) : super(key: key);

  @override
  State<JoinRequestBottomSheet> createState() => _JoinRequestBottomSheetState();
}

class _JoinRequestBottomSheetState extends State<JoinRequestBottomSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // 대기 중인 요청만 필터링 (대소문자 무시 및 다양한 표현 허용)
    final pendingRequests =
        widget.requests.where((req) {
          final status = req.status.toUpperCase();
          return status == 'PENDING';
        }).toList();

    // 각 요청의 상태 로깅
    for (var req in widget.requests) {
      debugPrint('요청 ID: ${req.id}, 상태: "${req.status}"');
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 바
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 제목
                  Row(
                    children: [
                      const Icon(Icons.person_add, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        '가입 요청 관리',
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${pendingRequests.length}개의 요청',
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 14,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 요청 목록
            Expanded(
              child:
                  pendingRequests.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: pendingRequests.length,
                        itemBuilder: (context, index) {
                          return _buildRequestItem(pendingRequests[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  // 요청 항목 위젯
  Widget _buildRequestItem(GroupJoinRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 정보
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage:
                      request.member.profileUrl != null
                          ? NetworkImage(request.member.profileUrl!)
                          : null,
                  child:
                      request.member.profileUrl == null
                          ? Text(
                            request.member.nickname.isNotEmpty
                                ? request.member.nickname[0]
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          )
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.member.nickname,
                        style: const TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        request.member.email,
                        style: const TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 14,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 요청 정보
            Text(
              '요청일: ${_formatDate(request.requestedAt)}',
              style: const TextStyle(
                fontFamily: 'Anemone_air',
                fontSize: 12,
                color: AppColors.mediumGray,
              ),
            ),

            const SizedBox(height: 16),

            // 버튼 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => _respondToRequest(request, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.background,
                    foregroundColor: Colors.red, // 텍스트 색상 빨간색으로 설정
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('거절'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _respondToRequest(request, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('승인'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 빈 상태 위젯
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text(
            '처리할 가입 요청이 없습니다',
            style: TextStyle(
              fontFamily: 'Anemone_air',
              fontSize: 16,
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  // 요청 처리 메서드
  Future<void> _respondToRequest(GroupJoinRequest request, bool accept) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final success = await groupProvider.respondToJoinRequest(
        groupId: widget.groupId,
        token: request.token,
        applicantId: request.memberId,
        accept: accept,
        adminComment: accept ? '가입을 승인했습니다.' : '가입을 거절했습니다.',
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                accept
                    ? '${request.member.nickname}님의 가입을 승인했습니다.'
                    : '${request.member.nickname}님의 가입을 거절했습니다.',
              ),
              backgroundColor: accept ? AppColors.primary : Colors.red,
            ),
          );

          // 상위 위젯에 요청 처리 완료 알림
          widget.onRequestProcessed();

          // 바텀시트 닫기
          Navigator.of(context).pop();
        } else {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('요청 처리에 실패했습니다: ${groupProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('요청 처리 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 날짜 포맷팅 헬퍼 메서드
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}
