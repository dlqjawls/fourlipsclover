import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../providers/group_provider.dart';
import '../../widgets/clover_loading_spinner.dart';
import '../../widgets/toast_bar.dart';
import 'group_widgets/empty_group_view.dart';
import 'group_widgets/group_list_view.dart';
import 'bottomsheet/group_create_bottom_sheet.dart';
import '../../services/invitation/deep_link_service.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({Key? key}) : super(key: key);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  bool _isError = false;
  bool _hasPendingInvitation = false;

  @override
  void initState() {
    super.initState();
    // initState에서는 직접 비동기 작업을 하지 않고, 다음 프레임에서 수행하도록 함
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchGroups();
      _checkPendingInvitation();
    });
  }

  // 저장된 초대가 있는지 확인
  Future<void> _checkPendingInvitation() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('pendingInvitationToken');

    if (token != null && mounted) {
      setState(() {
        _hasPendingInvitation = true;
      });
      debugPrint('저장된 초대 토큰 발견: $token');
    }
  }

  // 초대 화면으로 이동
  void _navigateToInvitationScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('pendingInvitationToken');

    if (token != null && mounted) {
      debugPrint('초대 화면으로 이동: $token');
      Navigator.of(
        context,
      ).pushNamed('/group/invitation', arguments: {'token': token}).then((_) {
        // 초대 화면에서 돌아오면 상태 업데이트
        _checkPendingInvitation();
      });
    } else {
      // 토큰이 없는 경우 사용자에게 알림
      ToastBar.clover('처리할 초대가 없습니다.');
    }
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
      ToastBar.clover('그룹 목록 로드 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provider의 isLoading 상태 감시
    final groupProvider = Provider.of<GroupProvider>(context);
    final isLoading = groupProvider.isLoading;

    return Scaffold(
      // 플로팅 액션 버튼 - 초대가 있을 때만 표시
      floatingActionButton:
          _hasPendingInvitation
              ? FloatingActionButton(
                heroTag: 'invitationFab',
                onPressed: _navigateToInvitationScreen,
                backgroundColor: AppColors.orange,
                tooltip: '그룹 초대 확인',
                child: const Icon(Icons.mail, color: Colors.white),
              )
              : null,

      body: LoadingOverlay(
        isLoading: isLoading,
        overlayColor: Colors.white.withOpacity(0.7),
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

              // 메인 콘텐츠
              Column(
                children: [
                  // 메인 콘텐츠 (에러 또는 그룹 목록)
                  Expanded(
                    child:
                        _isError
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: AppColors.red,
                                    size: 48,
                                  ),
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
                                      style: TextStyle(
                                        fontFamily: 'Anemone_air',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : Consumer<GroupProvider>(
                              builder: (context, groupProvider, child) {
                                final groups = groupProvider.groups;

                                return groups.isEmpty && !isLoading
                                    ? EmptyGroupView(
                                      onCreateGroup: () {
                                        _showGroupCreateBottomSheet(context);
                                      },
                                    )
                                    : groups.isEmpty
                                    ? SizedBox()
                                    : GroupListView(
                                      groups: groups,
                                      groupProvider: groupProvider,
                                      onCreateGroup: () {
                                        _showGroupCreateBottomSheet(context);
                                      },
                                    );
                              },
                            ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 그룹 생성 바텀 시트
  void _showGroupCreateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return const GroupCreateBottomSheet();
      },
    ).then((result) {
      if (result == true) {
        _fetchGroups();
      }
    });
  }
}
