import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import 'dart:math' as math;
import '../bottomsheet/notice_create_bottom_sheet.dart'; // 바텀시트 파일 임포트
import '../../../models/notice_item.dart';
import '../../../providers/plan_provider.dart'; // Provider 추가
import 'package:provider/provider.dart'; // Provider 추가

class PlanNoticeBoard extends StatefulWidget {
  final int planId;
  final int groupId;

  const PlanNoticeBoard({Key? key, required this.planId, required this.groupId})
    : super(key: key);

  @override
  State<PlanNoticeBoard> createState() => _PlanNoticeBoardState();
}

class _PlanNoticeBoardState extends State<PlanNoticeBoard> {
  List<NoticeItem> _notices = []; // 실제로는 API에서 가져올 예정
  final List<Color> _availableColors = [
    Colors.yellow.shade100, // 연한 노랑
    Colors.pink.shade100, // 연한 분홍
    Colors.blue.shade100, // 연한 파랑
    Colors.green.shade100, // 연한 초록
    Colors.orange.shade100, // 연한 주황
  ];

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    // 로딩 상태를 시작하기 위해 Provider 업데이트
    // PlanProvider 또는 별도의 LoadingProvider를 사용할 수 있습니다
    final planProvider = Provider.of<PlanProvider>(context, listen: false);
    planProvider.setLoading(true);

    try {
      // 여기서 실제로는 API 호출로 데이터를 가져올 예정
      // 임시 데이터
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 공지사항 목록 - 중요 항목을 먼저 정렬, 최대 6개로 제한
      final List<NoticeItem> noticeList = [
        NoticeItem(
          id: '1',
          content: '숙소 체크인: 12월 17일 15:00 - 제주 시티호텔, 사전 예약 완료',
          color: Colors.yellow.shade100,
          isImportant: true,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        NoticeItem(
          id: '3',
          content: '렌트카: 모닝 2대, 공항 픽업 (입국장 1층에서 만나요)',
          color: Colors.green.shade100,
          isImportant: true,
          createdAt: DateTime.now(),
        ),
        NoticeItem(
          id: '4',
          content: '여행 경비: 1인당 30만원 예상, 총무에게 20만원씩 모을 예정',
          color: Colors.pink.shade100,
          isImportant: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
        NoticeItem(
          id: '2',
          content: '12월 18일 해녀체험 예약했어요! 오전 10시까지 모이기',
          color: Colors.blue.shade100,
          isImportant: false,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        NoticeItem(
          id: '5',
          content: '준비물: 수영복, 선크림, 모자, 우산, 여분 옷',
          color: Colors.orange.shade100,
          isImportant: false,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];

      // 공지사항 수가 6개를 초과하면 6개로 제한
      if (noticeList.length > 6) {
        noticeList.length = 6;
      }

      setState(() {
        _notices = noticeList;
      });
    } catch (e) {
      // 에러 처리
      debugPrint('공지사항 로드 중 오류: $e');
    } finally {
      // 로딩 상태 종료
      planProvider.setLoading(false);
    }
  }

  // 공지사항 추가
  Future<void> _showAddNoticeBottomSheet() async {
    // 별도의 바텀시트 컴포넌트 사용
    showNoticeCreateBottomSheet(
      context: context,
      availableColors: _availableColors,
      onNoticeCreated: (newNotice) {
        setState(() {
          // 최대 6개 제한 확인
          if (_notices.length >= 6) {
            // 가장 오래된 비중요 공지사항 삭제
            final nonImportantIndex = _notices.indexWhere(
              (notice) => !notice.isImportant,
            );
            if (nonImportantIndex != -1) {
              _notices.removeAt(nonImportantIndex);
            } else {
              // 모두 중요 공지사항인 경우 가장 오래된 것 삭제
              _notices.removeLast();
            }
          }

          // 새 공지사항 추가 (중요 공지사항은 중요 공지사항들 중 맨 뒤에 추가)
          if (newNotice.isImportant) {
            // 마지막 중요 공지사항 위치 찾기
            final lastImportantIndex = _notices.lastIndexWhere(
              (notice) => notice.isImportant,
            );

            if (lastImportantIndex == -1) {
              // 중요 공지사항이 없으면 맨 앞에 추가
              _notices.insert(0, newNotice);
            } else {
              // 있으면 마지막 중요 공지사항 뒤에 추가
              _notices.insert(lastImportantIndex + 1, newNotice);
            }
          } else {
            // 중요하지 않은 공지사항은 가장 마지막에 추가
            _notices.add(newNotice);
          }
        });
      },
      maxNoticeCount: 6,
    );
  }

  // 공지사항 삭제 확인 다이얼로그
  Future<void> _showDeleteConfirmDialog(NoticeItem notice) async {
    // 위치를 계산하기 위한 RenderBox 가져오기
    final RenderBox? overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;

    // 삭제 확인 다이얼로그 표시
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 24,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '공지사항 삭제',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  '이 공지사항을 삭제하시겠습니까?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 취소 버튼
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // 다이얼로그 닫기
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                      ),
                      child: const Text('취소'),
                    ),
                    // 삭제 버튼
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // 다이얼로그 닫기
                        _deleteNotice(notice.id); // 공지사항 삭제
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('삭제'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 공지사항 삭제
  Future<void> _deleteNotice(String id) async {
    setState(() {
      _notices.removeWhere((notice) => notice.id == id);
    });

    // 여기서 실제로는 API 호출로 데이터를 삭제할 예정
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // 화이트보드 배경 디자인
        color: Colors.grey.shade100,
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
                  // 로딩 스피너 제거 - 전체 LoadingOverlay에서 처리
                  _notices.isEmpty
                      ? Center(
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
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 2.0,
                                  ),
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
                                  child: Icon(
                                    Icons.add,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      : _buildNoticeBoardLayout(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 공지사항 배치 레이아웃
  Widget _buildNoticeBoardLayout() {
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
            ...List.generate(_notices.length, (index) {
              return LayoutId(
                id: 'notice_$index',
                child: _buildNoticeItem(_notices[index], index),
              );
            }),

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

  // 공지사항 아이템 위젯 (메모지 스타일)
  Widget _buildNoticeItem(NoticeItem notice, int index) {
    // 회전 각도 계산 (살짝 기울임)
    final random = math.Random(notice.id.hashCode);
    final rotation =
        (random.nextDouble() * 10 - 5) * math.pi / 180; // -5도에서 5도 사이 랜덤 회전

    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 160,
        constraints: const BoxConstraints(minHeight: 120, maxHeight: 200),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: notice.color,
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
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
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

                  // 날짜 정보 제거됨 (요청에 따라)
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

            // 삭제 버튼 (메모 우상단) - 흰 배경 제거
            Positioned(
              top: 2,
              right: 2,
              child: InkWell(
                onTap: () => _showDeleteConfirmDialog(notice), // 삭제 확인 다이얼로그 표시
                child: Icon(Icons.close, size: 14, color: Colors.grey.shade700),
              ),
            ),
          ],
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