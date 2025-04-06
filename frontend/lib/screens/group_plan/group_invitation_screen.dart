// lib/screens/group/group_invitation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/group_provider.dart';
import '../../widgets/clover_loading_spinner.dart';

class GroupInvitationScreen extends StatefulWidget {
  final String token;
  
  const GroupInvitationScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<GroupInvitationScreen> createState() => _GroupInvitationScreenState();
}

class _GroupInvitationScreenState extends State<GroupInvitationScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _invitationInfo;
  
  @override
  void initState() {
    super.initState();
    _loadInvitationInfo();
  }
  
  // 초대 정보 로드
  Future<void> _loadInvitationInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final result = await groupProvider.checkInvitationLink(widget.token);
      
      if (mounted) {
        setState(() {
          _invitationInfo = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '초대 정보를 불러올 수 없습니다: $e';
          _isLoading = false;
        });
      }
    }
  }
  
  // 그룹 가입 요청
  Future<void> _joinGroup() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final success = await groupProvider.joinGroup(widget.token);
      
      if (mounted) {
        if (success) {
          // 성공 메시지 표시 후 홈 화면으로 이동
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('그룹 가입 요청이 완료되었습니다')),
          );
          
          // 그룹 목록 새로고침
          await groupProvider.fetchMyGroups();
          
          // 홈 화면으로 이동
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        } else {
          setState(() {
            _error = '그룹 가입 요청에 실패했습니다: ${groupProvider.error}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '그룹 가입 요청 중 오류가 발생했습니다: $e';
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('그룹 초대'),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _buildContent(),
      ),
    );
  }
  
  Widget _buildContent() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              '오류가 발생했습니다',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _loadInvitationInfo,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }
    
    if (_invitationInfo == null) {
      return const Center(child: Text('초대 정보를 불러오는 중입니다...'));
    }
    
    // 그룹 정보 표시 및 가입 버튼
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 그룹 이름
          Text(
            _invitationInfo!['groupName'] ?? '알 수 없는 그룹',
            style: const TextStyle(
              fontFamily: 'Anemone',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 그룹 설명
          Text(
            _invitationInfo!['description'] ?? '그룹 설명이 없습니다',
            style: TextStyle(
              fontFamily: 'Anemone_air',
              fontSize: 16,
              color: AppColors.darkGray,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 그룹 정보 카드
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 멤버 수
                  Row(
                    children: [
                      const Icon(Icons.people, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        '멤버 ${_invitationInfo!['memberCount'] ?? 0}명',
                        style: const TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 그룹장 정보
                  Row(
                    children: [
                      const Icon(Icons.person, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        '그룹장: ${_invitationInfo!['ownerName'] ?? '알 수 없음'}',
                        style: const TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 그룹 공개 여부
                  Row(
                    children: [
                      Icon(
                        _invitationInfo!['isPublic'] == true
                            ? Icons.public
                            : Icons.lock,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _invitationInfo!['isPublic'] == true
                            ? '공개 그룹'
                            : '비공개 그룹',
                        style: const TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const Spacer(),
          
          // 가입 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _joinGroup,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '그룹 가입 요청하기',
                style: TextStyle(
                  fontFamily: 'Anemone_air',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 취소 버튼
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '취소',
                style: TextStyle(
                  fontFamily: 'Anemone_air',
                  fontSize: 16,
                  color: AppColors.mediumGray,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}