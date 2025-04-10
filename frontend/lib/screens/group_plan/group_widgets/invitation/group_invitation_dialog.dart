// lib/screens/group/group_widgets/group_invitation_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../config/theme.dart';
import '../../../../widgets/toast_bar.dart';

class GroupInvitationDialog extends StatelessWidget {
  final String inviteUrl;
  final DateTime? expiryDate;
  final Function(String) onShareKakao;

  const GroupInvitationDialog({
    Key? key,
    required this.inviteUrl,
    this.expiryDate,
    required this.onShareKakao,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 제목
          const Text(
            '그룹 초대 링크',
            style: TextStyle(
              fontFamily: 'Anemone',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),

          const SizedBox(height: 20),

          // 링크 표시 영역
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.verylightGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    inviteUrl,
                    style: const TextStyle(
                      fontFamily: 'Anemone_air',
                      fontSize: 14,
                      color: AppColors.darkGray,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.copy,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: inviteUrl));
                    ToastBar.clover('초대 링크 복사 완료');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 만료 정보
          if (expiryDate != null)
            Padding(padding: const EdgeInsets.only(bottom: 16)),

          // 공유 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 카카오톡으로 공유 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint('카카오톡 공유 버튼 클릭: $inviteUrl');
                    try {
                      // 함수 호출 결과를 무시하고 Future 체인을 끊어버림
                      onShareKakao(inviteUrl);

                      // 다이얼로그를 닫음 (선택적)
                      Navigator.of(context).pop();
                    } catch (e) {
                      debugPrint('카카오 공유 호출 오류: $e');
                      ToastBar.clover('카카오톡 공유 시작 실패');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: const Color(0xFFFEE500), // 카카오 색상
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/kakao_symbol.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text('카카오톡으로 공유'),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 닫기 버튼
          TextButton(
            child: const Text(
              '닫기',
              style: TextStyle(
                fontFamily: 'Anemone_air',
                fontSize: 16,
                color: AppColors.mediumGray,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  String _formatExpiryDate(DateTime date) {
    // 날짜 형식 포맷팅
    return '${date.year}년 ${date.month}월 ${date.day}일 ${date.hour}시 ${date.minute}분';
  }
}
