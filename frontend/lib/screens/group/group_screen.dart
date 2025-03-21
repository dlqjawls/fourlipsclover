import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/group_provider.dart';
import 'widgets/empty_group_view.dart';
import 'widgets/group_list_view.dart';
import 'widgets/group_create_dialog.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({Key? key}) : super(key: key);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  bool _isLoading = true;
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
      _isLoading = true;
      _isError = false;
    });

    try {
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
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

            // 로딩 상태
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            // 에러 상태
            else if (_isError)
              Center(
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
                  
                  return groups.isEmpty
                      ? EmptyGroupView(
                          onCreateGroup: () => _showGroupCreateDialog(context),
                        )
                      : GroupListView(
                          groups: groups,
                          groupProvider: groupProvider,
                          onCreateGroup: () => _showGroupCreateDialog(context),
                        );
                },
              ),
          ],
        ),
      ),
    );
  }

  // 그룹 생성 다이얼로그
  void _showGroupCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GroupCreateDialog();
      },
    );
  }
}