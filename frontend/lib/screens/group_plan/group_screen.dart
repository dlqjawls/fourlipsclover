import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/group_provider.dart';
import '../../widgets/clover_loading_spinner.dart'; // 로딩 스피너 추가
import 'group_widgets/empty_group_view.dart';
import 'group_widgets/group_list_view.dart';
import 'bottomsheet/group_create_bottom_sheet.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({Key? key}) : super(key: key);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    // initState에서는 직접 비동기 작업을 하지 않고, 다음 프레임에서 수행하도록 함
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchGroups();
    });
  }

  // 그룹 목록 가져오기
  Future<void> _fetchGroups() async {
    if (!mounted) return;

    setState(() {
      _isError = false;
    });

    try {
      // GroupProvider의 fetchMyGroups 메서드는 내부적으로 _isLoading을 관리함
      await Provider.of<GroupProvider>(context, listen: false).fetchMyGroups();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '그룹 목록을 불러오는데 실패했습니다.',
            style: TextStyle(fontFamily: 'Anemone_air'),
          ),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provider의 isLoading 상태 감시
    final groupProvider = Provider.of<GroupProvider>(context);
    final isLoading = groupProvider.isLoading;
    
    return Scaffold(
      body: LoadingOverlay( // LoadingOverlay로 감싸기
        isLoading: isLoading, // Provider의 로딩 상태 사용
        overlayColor: Colors.white.withOpacity(0.7), // 배경색 조정 (선택사항)
        child: RefreshIndicator(
          onRefresh: _fetchGroups,
          child: Stack(
            children: [
              // 우측 하단에 배경 이미지
              Positioned(
                bottom: -250,
                right: -280,
                child: Opacity(
                  opacity: 0.3,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 800,
                    height: 800,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // 에러 상태
              if (_isError)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: AppColors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        '그룹 목록을 불러오는데 실패했습니다.',
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          color: AppColors.darkGray,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchGroups,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: Text(
                          '다시 시도',
                          style: TextStyle(fontFamily: 'Anemone_air'),
                        ),
                      ),
                    ],
                  ),
                )
              // 정상 상태 - 그룹이 있는 경우와 없는 경우
              else
                Consumer<GroupProvider>(
                  builder: (context, groupProvider, child) {
                    final groups = groupProvider.groups;
                    print("Consumer<GroupProvider> 빌드 - 그룹 개수: ${groups.length}");

                    return groups.isEmpty && !isLoading // 로딩 중이 아닐 때만 빈 화면 표시
                        ? EmptyGroupView(
                          onCreateGroup: () {
                            print("EmptyGroupView - 그룹 생성 버튼 클릭");
                            _showGroupCreateBottomSheet(context);
                          },
                        )
                        : groups.isEmpty 
                          ? SizedBox() // 로딩 중이고 데이터가 없으면 빈 화면
                          : GroupListView(
                            groups: groups,
                            groupProvider: groupProvider,
                            onCreateGroup: () {
                              print("GroupListView - 그룹 생성 버튼 클릭");
                              _showGroupCreateBottomSheet(context);
                            },
                          );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 그룹 생성 바텀 시트
  void _showGroupCreateBottomSheet(BuildContext context) {
    print("_showGroupCreateBottomSheet 함수 시작");

    try {
      print("showModalBottomSheet 호출 전");
      showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (BuildContext bottomSheetContext) {
              print("바텀시트 builder 호출됨");
              return const GroupCreateBottomSheet();
            },
          )
          .then((result) {
            print("바텀시트 닫힘 - 결과: $result");
            if (result == true) {
              _fetchGroups();
            }
          })
          .catchError((error) {
            print("바텀시트 오류 발생: $error");
          });
      print("showModalBottomSheet 호출 후");
    } catch (e) {
      print("_showGroupCreateBottomSheet 예외 발생: $e");
    }
  }
}