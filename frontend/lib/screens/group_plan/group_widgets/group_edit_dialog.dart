// screens/group/widgets/group_edit_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/group/group_model.dart';
import '../../../providers/group_provider.dart';
import '../../../config/theme.dart';
import '../../../widgets/toast_bar.dart';

class GroupEditDialog extends StatefulWidget {
  final Group group;
  final Function(Group) onUpdate;

  const GroupEditDialog({Key? key, required this.group, required this.onUpdate})
    : super(key: key);

  @override
  State<GroupEditDialog> createState() => _GroupEditDialogState();
}

class _GroupEditDialogState extends State<GroupEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _isPublic;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group.name);
    _descriptionController = TextEditingController(
      text: widget.group.description,
    );
    _isPublic = widget.group.isPublic;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);

    return AlertDialog(
      title: Text(
        '그룹 정보 수정',
        style: TextStyle(
          fontFamily: 'Anemone_air',
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
      content:
          groupProvider.isLoading
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
              : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 그룹 이름 입력 필드
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: '그룹 이름',
                          labelStyle: TextStyle(color: AppColors.primaryDark),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '그룹 이름을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 그룹 설명 입력 필드
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: '그룹 설명',
                          labelStyle: TextStyle(color: AppColors.primaryDark),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '그룹 설명을 입력해주세요';
                          }
                          return null;
                        },
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // 공개 여부 토글
                      Row(
                        children: [
                          Text(
                            '공개 그룹',
                            style: TextStyle(color: AppColors.darkGray),
                          ),
                          const Spacer(),
                          Switch(
                            value: _isPublic,
                            onChanged: (value) {
                              setState(() {
                                _isPublic = value;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      actions: [
        TextButton(
          onPressed:
              groupProvider.isLoading
                  ? null
                  : () => Navigator.of(context).pop(),
          child: Text('취소', style: TextStyle(color: AppColors.darkGray)),
        ),
        ElevatedButton(
          onPressed: groupProvider.isLoading ? null : _updateGroup,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('수정하기'),
        ),
      ],
    );
  }

  // 그룹 정보 업데이트 Provider 사용
  Future<void> _updateGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    final success = await groupProvider.updateGroup(
      groupId: widget.group.groupId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      isPublic: _isPublic,
    );

    if (success) {
      // 성공 시 콜백 호출
      final updatedGroup = groupProvider.groups.firstWhere(
        (group) => group.groupId == widget.group.groupId,
      );
      widget.onUpdate(updatedGroup);

      // 다이얼로그 닫기
      Navigator.of(context).pop();

      // 성공 메시지 표시
      ToastBar.clover('그룹 정보 수정 완료');
    } else {
      // 에러 메시지 표시
      ToastBar.clover('그룹 정보 수정 실패');
    }
  }
}
