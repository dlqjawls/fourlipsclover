import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../config/theme.dart';
import '../../../models/notice/notice_model.dart';
import '../../../providers/notice_provider.dart';
import '../bottomsheet/notice_create_bottom_sheet.dart';
import '../bottomsheet/notice_edit_bottom_sheet.dart'; // 수정 바텀시트 추가

class PlanNoticeBoard extends StatefulWidget {
  final int planId;
  final int groupId;

  const PlanNoticeBoard({Key? key, required this.planId, required this.groupId})
    : super(key: key);

  @override
  State<PlanNoticeBoard> createState() => _PlanNoticeBoardState();
}

class _PlanNoticeBoardState extends State<PlanNoticeBoard> {
  List<NoticeModel> _notices = [];

  @override
  void initState() {
    super.initState();
    // 직접 호출하지 않고 다음 프레임으로 예약
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotices();
    });
  }

  // 공지사항 목록 가져오기
  Future<void> _loadNotices() async {
    final noticeProvider = Provider.of<NoticeProvider>(context, listen: false);

    // 먼저 로딩 상태를 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      noticeProvider.setLoading(true);
    });

    try {
      final notices = await noticeProvider.fetchNotices(widget.planId);
      if (mounted) {
        setState(() {
          _notices = notices;
        });
      }
    } catch (e) {
      debugPrint('공지사항 로드 중 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('공지사항을 불러오는데 실패했습니다: $e')));
      }
    } finally {
      if (mounted) {
        // 로딩 상태 해제도 다음 프레임으로 예약
        WidgetsBinding.instance.addPostFrameCallback((_) {
          noticeProvider.setLoading(false);
        });
      }
    }
  }

  // 공지사항 추가 바텀시트 표시
  void _showAddNoticeBottomSheet() {
    final noticeProvider = Provider.of<NoticeProvider>(context, listen: false);

    // 이용 가능한 색상 리스트 만들기
    final availableColors = [
      AppColors.noticeMemoYellow,
      AppColors.noticeMemoRed,
      AppColors.noticeMemoBlue,
      AppColors.noticeMemoGreen,
      AppColors.noticeMemoOrange,
      AppColors.noticeMemoViolet,
    ];

    showNoticeCreateBottomSheet(
      context: context,
      availableColors: availableColors,
      maxNoticeCount: 6,
      onNoticeCreated: (newNotice) async {
        try {
          // NoticeItem에서 NoticeModel로 변환
          final notice = NoticeModel(
            planId: widget.planId,
            isImportant: newNotice.isImportant,
            color: noticeProvider.getNoticeColorFromColor(newNotice.color),
            content: newNotice.content,
          );

          // API 통신으로 공지사항 생성
          await noticeProvider.createNotice(widget.planId, notice);

          // 생성 후 공지사항 목록 다시 불러오기
          _loadNotices();

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('공지사항이 추가되었습니다')));
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('공지사항 추가에 실패했습니다: $e')));
        }
      },
    );
  }

  // 공지사항 수정 바텀시트 표시
  void _showEditNoticeBottomSheet(NoticeModel notice) {
    final noticeProvider = Provider.of<NoticeProvider>(context, listen: false);

    // 이용 가능한 색상 리스트 만들기
    final availableColors = [
      AppColors.noticeMemoYellow,
      AppColors.noticeMemoRed,
      AppColors.noticeMemoBlue,
      AppColors.noticeMemoGreen,
      AppColors.noticeMemoOrange,
      AppColors.noticeMemoViolet,
    ];

    showNoticeEditBottomSheet(
      context: context,
      notice: notice,
      availableColors: availableColors,
      onNoticeUpdated: (updatedNotice) async {
        try {
          // NoticeEditItem에서 NoticeModel로 변환
          final noticeToUpdate = NoticeModel(
            planNoticeId: notice.planNoticeId, // 기존 ID 유지
            planId: widget.planId,
            isImportant: updatedNotice.isImportant,
            color: noticeProvider.getNoticeColorFromColor(updatedNotice.color),
            content: updatedNotice.content,
            createdAt: notice.createdAt, // 기존 생성일 유지
          );

          // API 통신으로 공지사항 수정
          await noticeProvider.updateNotice(
            widget.planId,
            notice.planNoticeId!,
            noticeToUpdate,
          );

          // 수정 후 공지사항 목록 다시 불러오기
          _loadNotices();

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('공지사항이 수정되었습니다')));
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('공지사항 수정에 실패했습니다: $e')));
        }
      },
      onNoticeDeleted: () async {
        await _deleteNotice(notice.planNoticeId!);
      },
    );
  }

  // 공지사항 삭제
  Future<void> _deleteNotice(int planNoticeId) async {
    final noticeProvider = Provider.of<NoticeProvider>(context, listen: false);

    try {
      await noticeProvider.deleteNotice(widget.planId, planNoticeId);
      _loadNotices(); // 목록 새로고침

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('공지사항이 삭제되었습니다')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('공지사항 삭제에 실패했습니다: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final noticeProvider = Provider.of<NoticeProvider>(context);
    final isLoading = noticeProvider.isLoading;

    return Container(
      decoration: BoxDecoration(
        // 화이트보드 배경 디자인
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 화이트보드 느낌의 배경
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 3,
                ), // 테두리 두께 증가
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // 그림자 강화
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _notices.isEmpty
                      ? _buildEmptyState()
                      : _buildNoticeBoardLayout(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 공지사항이 없는 경우 표시할 위젯
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sticky_note_2_outlined,
            size: 72,
            color: AppColors.lightGray,
          ),
          const SizedBox(height: 16),
          Text(
            '등록된 공지사항이 없어요',
            style: TextStyle(
              fontFamily: 'Anemone_air',
              fontSize: 24,
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '새로운 공지사항을 추가해보세요',
            style: TextStyle(
              fontFamily: 'Anemone_air',
              fontSize: 16,
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _showAddNoticeBottomSheet,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.verylightGray,
                border: Border.all(color: AppColors.primary, width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.add, color: AppColors.primary, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 공지사항 배치 레이아웃
  Widget _buildNoticeBoardLayout() {
    final noticeProvider = Provider.of<NoticeProvider>(context, listen: false);

    // 화면 크기 기준으로 열 수 계산
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = 160.0; // 각 메모 아이템의 기본 너비
    final columns = (screenWidth - 32) ~/ itemWidth; // 한 줄에 배치할 메모 개수
    final showAddButton = _notices.length < 6; // 6개 미만일 때만 버튼 표시

    return Stack(
      children: [
        // 화이트보드 질감 (강화) - 이미지 참조 제거하고 색상과 그라데이션으로 표현
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              // 그라데이션으로 질감 표현
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
                stops: const [0.4, 1.0],
              ),
            ),
            // 보드 테두리 효과 추가
            foregroundDecoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 3),
              borderRadius: BorderRadius.circular(8),
              gradient: RadialGradient(
                colors: [Colors.transparent, Colors.grey.withOpacity(0.1)],
                center: Alignment.center,
                radius: 1.5,
              ),
            ),
          ),
        ),

        // 공지사항 메모들과 추가 버튼 배치
        CustomMultiChildLayout(
          delegate: NoticeBoardLayoutDelegate(
            itemCount: _notices.length,
            columns: columns,
            showAddButton: showAddButton,
          ),
          children: [
            // 공지사항 메모들
            ..._notices.asMap().entries.map((entry) {
              final index = entry.key;
              final notice = entry.value;

              // Provider에서 색상 가져오기
              final noticeColor = noticeProvider.getColorFromNoticeColor(
                notice.color,
              );

              return LayoutId(
                id: 'notice_$index',
                child: _buildNoticeItem(notice, noticeColor, index),
              );
            }).toList(),

            // 추가 버튼 (6개 미만일 때만)
            if (showAddButton)
              LayoutId(
                id: 'add_button',
                child: GestureDetector(
                  onTap: _showAddNoticeBottomSheet,
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.verylightGray,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // 공지사항 아이템 위젯 (메모지 스타일) - 클릭 시 수정 바텀시트 열기 추가, 삭제 버튼 제거
  Widget _buildNoticeItem(NoticeModel notice, Color noticeColor, int index) {
    // 회전 각도 계산 (살짝 기울임)
    final random = math.Random(notice.planNoticeId?.hashCode ?? index);
    final rotation =
        (random.nextDouble() * 10 - 5) * math.pi / 180; // -5도에서 5도 사이 랜덤 회전

    return GestureDetector(
      onTap: () {
        // 메모 클릭 시 수정 바텀시트 열기
        if (notice.planNoticeId != null) {
          _showEditNoticeBottomSheet(notice);
        }
      },
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: 160,
          constraints: const BoxConstraints(minHeight: 120, maxHeight: 200),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: noticeColor,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // 그림자 강화
                blurRadius: 4,
                offset: const Offset(1, 3), // 그림자 위치 조정
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none, // 자식 위젯이 부모 밖으로 나갈 수 있도록 설정
            children: [
              // 메모 내용
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 12), // 상단 여백 증가
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 중요 표시
                    if (notice.isImportant)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '중요',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    // 공지사항 내용
                    Text(
                      notice.content,
                      style: const TextStyle(fontSize: 14, height: 1.3),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 자석 핀 (위쪽 중앙) - 위치 조정하여 완전히 보이도록 수정
              Positioned(
                top: 3, // 자석이 보이도록 위치 조정
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color:
                          notice.isImportant
                              ? Colors.red.shade300
                              : Colors.blue.shade300,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
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

// 공지사항 메모와 추가 버튼 배치를 위한 커스텀 레이아웃 델리게이트
class NoticeBoardLayoutDelegate extends MultiChildLayoutDelegate {
  final int itemCount;
  final int columns;
  final bool? showAddButton; // null 허용으로 변경

  NoticeBoardLayoutDelegate({
    required this.itemCount,
    required this.columns,
    this.showAddButton,
  });

  @override
  void performLayout(Size size) {
    // 각 아이템의 크기 및 위치 계산
    final itemWidth = size.width / columns;
    const itemHeight = 160.0;

    const horizontalSpacing = 8.0;
    const verticalSpacing = 16.0;

    // 공지사항 메모 배치
    for (int i = 0; i < itemCount; i++) {
      final id = 'notice_$i';

      if (hasChild(id)) {
        // 아이템의 열과 행 인덱스 계산
        final col = i % columns;
        final row = i ~/ columns;

        // 살짝 랜덤하게 위치 조정 (자연스러운 느낌)
        final random = math.Random(i);
        final offsetX = (random.nextDouble() * 10 - 5);
        final offsetY = (random.nextDouble() * 10 - 5);

        // 좌표 계산
        final x = col * itemWidth + horizontalSpacing + offsetX;
        final y = row * itemHeight + verticalSpacing + offsetY;

        // 아이템의 레이아웃 크기 구하기
        final childSize = layoutChild(
          id,
          BoxConstraints.loose(
            Size(
              itemWidth - horizontalSpacing * 2,
              itemHeight - verticalSpacing,
            ),
          ),
        );

        // 아이템 배치
        positionChild(id, Offset(x, y));
      }
    }

    // 추가 버튼 배치 (다음 공지사항이 올 위치에)
    if (showAddButton == true && hasChild('add_button')) {
      final nextCol = itemCount % columns;
      final nextRow = itemCount ~/ columns;

      final x = nextCol * itemWidth + horizontalSpacing;
      final y = nextRow * itemHeight + verticalSpacing;

      // 아이템의 레이아웃 크기 구하기
      final childSize = layoutChild(
        'add_button',
        BoxConstraints.loose(
          Size(itemWidth - horizontalSpacing * 2, itemHeight - verticalSpacing),
        ),
      );

      // 추가 버튼 위치 계산 (셀의 가운데에 배치)
      final centerX = nextCol * itemWidth + (itemWidth / 2);
      final centerY = nextRow * itemHeight + (itemHeight / 2);

      // 버튼 크기의 절반을 빼서 가운데 정렬
      final buttonHalfWidth = childSize.width / 2;
      final buttonHalfHeight = childSize.height / 2;

      positionChild(
        'add_button',
        Offset(centerX - buttonHalfWidth, centerY - buttonHalfHeight),
      );
    }
  }

  @override
  bool shouldRelayout(NoticeBoardLayoutDelegate oldDelegate) {
    return oldDelegate.itemCount != itemCount ||
        oldDelegate.columns != columns ||
        oldDelegate.showAddButton != showAddButton;
  }
}
