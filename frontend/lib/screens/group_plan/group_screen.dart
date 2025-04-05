import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../providers/group_provider.dart';
import '../../widgets/clover_loading_spinner.dart';
import 'group_widgets/empty_group_view.dart';
import 'group_widgets/group_list_view.dart';
import 'group_widgets/group_invitation_banner.dart';
import 'bottomsheet/group_create_bottom_sheet.dart';
import '../../services/deep_link_service.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({Key? key}) : super(key: key);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  bool _isError = false;
  String? _pendingInvitationToken;
  Map<String, dynamic>? _pendingInvitationInfo;
  bool _isCheckingInvitation = false;

  @override
  void initState() {
    super.initState();
    // initState에서는 직접 비동기 작업을 하지 않고, 다음 프레임에서 수행하도록 함
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchGroups();
      _checkPendingInvitation();
    });
  }

  // 대기 중인 초대장 확인
  Future<void> _checkPendingInvitation() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('pendingInvitationToken');
    
    if (token != null && mounted) {
      setState(() {
        _pendingInvitationToken = token;
        _isCheckingInvitation = true;
      });
      
      try {
        final groupProvider = Provider.of<GroupProvider>(context, listen: false);
        final invitationInfo = await groupProvider.checkInvitationLink(token);
        
        if (mounted && invitationInfo != null) {
          setState(() {
            _pendingInvitationInfo = invitationInfo;
            _isCheckingInvitation = false;
          });
        } else {
          // 정보를 가져오지 못한 경우 토큰 삭제
          if (mounted) {
            await prefs.remove('pendingInvitationToken');
            setState(() {
              _pendingInvitationToken = null;
              _isCheckingInvitation = false;
            });
          }
        }
      } catch (e) {
        debugPrint('초대 정보 확인 중 오류: $e');
        if (mounted) {
          setState(() {
            _isCheckingInvitation = false;
          });
        }
      }
    }
  }

  // 초대 수락
  Future<void> _acceptInvitation() async {
    if (_pendingInvitationToken == null) return;
    
    setState(() {
      _isCheckingInvitation = true;
    });
    
    try {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final success = await groupProvider.joinGroup(_pendingInvitationToken!);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('그룹 가입 요청이 완료되었습니다')),
          );
          
          // 그룹 목록 새로고침
          await groupProvider.fetchMyGroups();
          
          // 대기 중인 초대 정보 삭제
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('pendingInvitationToken');
          
          setState(() {
            _pendingInvitationToken = null;
            _pendingInvitationInfo = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(groupProvider.error ?? '그룹 가입 요청에 실패했습니다'),
              backgroundColor: AppColors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('그룹 가입 요청 중 오류가 발생했습니다: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingInvitation = false;
        });
      }
    }
  }

  // 초대 거절
  Future<void> _declineInvitation() async {
    // 대기 중인 초대 정보 삭제
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pendingInvitationToken');
    
    if (mounted) {
      setState(() {
        _pendingInvitationToken = null;
        _pendingInvitationInfo = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('그룹 초대를 거절했습니다')),
      );
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
    final isLoading = groupProvider.isLoading || _isCheckingInvitation;
    
    return Scaffold(
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
                  // 초대 배너 - 대기 중인 초대가 있을 때만 표시
                  if (_pendingInvitationToken != null && _pendingInvitationInfo != null)
                    GroupInvitationBanner(
                      groupName: _pendingInvitationInfo!['groupName'] ?? '그룹',
                      onAccept: _acceptInvitation,
                      onDecline: _declineInvitation,
                    ),
                  
                  // 메인 콘텐츠 (에러 또는 그룹 목록)
                  Expanded(
                    child: _isError
                      ? Center(
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