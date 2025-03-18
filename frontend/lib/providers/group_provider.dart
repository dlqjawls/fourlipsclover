import 'package:flutter/foundation.dart';
import '../models/group_model.dart';

class GroupProvider with ChangeNotifier {
  // 사용자의 그룹 목록
  List<Group> _groups = [];
  
  // 현재 선택된 그룹
  Group? _selectedGroup;
  
  // Getters
  List<Group> get groups => _groups;
  Group? get selectedGroup => _selectedGroup;
  
  // 그룹 목록 설정 (API 호출 후)
  void setGroups(List<Group> groups) {
    _groups = groups;
    notifyListeners();
  }
  
  // 그룹 선택
  void selectGroup(int groupId) {
    _selectedGroup = _groups.firstWhere(
      (group) => group.groupId == groupId,
      orElse: () => throw Exception('그룹을 찾을 수 없습니다'),
    );
    notifyListeners();
  }
  
  // 새 그룹 추가
  void addGroup({
    required String name,
    required String description,
    required bool isPublic,
    required int memberId,
  }) {
    // 임시 ID 할당 (실제로는 API에서 받은 ID 사용)
    final newGroupId = _groups.isEmpty ? 1 : _groups.map((g) => g.groupId).reduce((a, b) => a > b ? a : b) + 1;
    
    final newGroup = Group(
      groupId: newGroupId,
      memberId: memberId,
      name: name,
      description: description,
      isPublic: isPublic,
      createdAt: DateTime.now().toIso8601String(),
      members: [
        GroupMember(
          userId: memberId,
          nickname: '나', // 실제 사용자 닉네임으로 수정 필요
          role: 'MANAGER', // 생성자는 기본적으로 관리자 역할
        ),
      ],
    );
    
    _groups.add(newGroup);
    _selectedGroup = newGroup; // 새 그룹 자동 선택
    notifyListeners();
    
    // TODO: API 호출하여 서버에 그룹 생성 요청
    // 이후 응답 받은 실제 그룹 정보로 업데이트
  }
  
  // 그룹 정보 업데이트
  void updateGroup({
    required int groupId,
    String? name,
    String? description,
    bool? isPublic,
  }) {
    final index = _groups.indexWhere((group) => group.groupId == groupId);
    if (index != -1) {
      _groups[index] = _groups[index].copyWith(
        name: name,
        description: description,
        isPublic: isPublic,
        updatedAt: DateTime.now().toIso8601String(),
      );
      
      if (_selectedGroup?.groupId == groupId) {
        _selectedGroup = _groups[index];
      }
      
      notifyListeners();
      
      // TODO: API 호출하여 서버에 그룹 업데이트 요청
    }
  }
  
  // 그룹 삭제
  void deleteGroup(int groupId) {
    _groups.removeWhere((group) => group.groupId == groupId);
    
    if (_selectedGroup?.groupId == groupId) {
      _selectedGroup = _groups.isNotEmpty ? _groups.first : null;
    }
    
    notifyListeners();
    
    // TODO: API 호출하여 서버에 그룹 삭제 요청
  }
  
  // 그룹 초대 링크 생성 (임시 구현)
  String generateInviteLink(int groupId) {
    // 실제 구현에서는 API를 통해 초대 링크 생성
    return 'https://yourapp.com/invite/$groupId/${DateTime.now().millisecondsSinceEpoch}';
  }
  
  // 멤버 추가
  void addMember(int groupId, GroupMember member) {
    final index = _groups.indexWhere((group) => group.groupId == groupId);
    if (index != -1) {
      final updatedMembers = [..._groups[index].members, member];
      _groups[index] = _groups[index].copyWith(
        members: updatedMembers,
        updatedAt: DateTime.now().toIso8601String(),
      );
      
      if (_selectedGroup?.groupId == groupId) {
        _selectedGroup = _groups[index];
      }
      
      notifyListeners();
      
      // TODO: API 호출하여 서버에 멤버 추가 요청
    }
  }
  
  // 멤버 역할 변경
  void updateMemberRole(int groupId, int userId, String newRole) {
    final groupIndex = _groups.indexWhere((group) => group.groupId == groupId);
    if (groupIndex != -1) {
      final memberIndex = _groups[groupIndex].members.indexWhere((m) => m.userId == userId);
      if (memberIndex != -1) {
        final updatedMembers = [..._groups[groupIndex].members];
        updatedMembers[memberIndex] = GroupMember(
          userId: userId,
          nickname: updatedMembers[memberIndex].nickname,
          role: newRole,
        );
        
        _groups[groupIndex] = _groups[groupIndex].copyWith(
          members: updatedMembers,
          updatedAt: DateTime.now().toIso8601String(),
        );
        
        if (_selectedGroup?.groupId == groupId) {
          _selectedGroup = _groups[groupIndex];
        }
        
        notifyListeners();
        
        // TODO: API 호출하여 서버에 멤버 역할 변경 요청
      }
    }
  }
  
  // 멤버 제거
  void removeMember(int groupId, int userId) {
    final groupIndex = _groups.indexWhere((group) => group.groupId == groupId);
    if (groupIndex != -1) {
      final updatedMembers = _groups[groupIndex].members.where((m) => m.userId != userId).toList();
      
      _groups[groupIndex] = _groups[groupIndex].copyWith(
        members: updatedMembers,
        updatedAt: DateTime.now().toIso8601String(),
      );
      
      if (_selectedGroup?.groupId == groupId) {
        _selectedGroup = _groups[groupIndex];
      }
      
      notifyListeners();
      
      // TODO: API 호출하여 서버에 멤버 제거 요청
    }
  }
}