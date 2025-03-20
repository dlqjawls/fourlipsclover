// models/group_member_model.dart
class GroupMember {
  final String id;
  final String name;
  final String? profileImage;
  final String role; // '그룹장', '총무', '멤버' 등

  GroupMember({
    required this.id,
    required this.name,
    this.profileImage,
    required this.role,
  });
}