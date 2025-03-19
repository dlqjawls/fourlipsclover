import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/group_provider.dart';
import '../../../widgets/custom_switch.dart';

class GroupCreateDialog extends StatefulWidget {
  @override
  _GroupCreateDialogState createState() => _GroupCreateDialogState();
}

class _GroupCreateDialogState extends State<GroupCreateDialog> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();
  bool _isPublic = false;
  bool _isNameEmpty = false;
  int _nameLength = 0;
  int _descriptionLength = 0;

  @override
  void initState() {
    super.initState();
    _groupNameController.addListener(_updateNameLength);
    _groupDescriptionController.addListener(_updateDescriptionLength);
  }

  void _updateNameLength() {
    setState(() {
      _nameLength = _groupNameController.text.length;
      if (_isNameEmpty && _groupNameController.text.trim().isNotEmpty) {
        _isNameEmpty = false;
      }
    });
  }

  void _updateDescriptionLength() {
    setState(() {
      _descriptionLength = _groupDescriptionController.text.length;
    });
  }

  @override
  void dispose() {
    _groupNameController.removeListener(_updateNameLength);
    _groupDescriptionController.removeListener(_updateDescriptionLength);
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isNameMaxLength = _nameLength == 10;
    final bool isDescriptionMaxLength = _descriptionLength == 20;

    return AlertDialog(
      title: Text(
        '새 그룹 생성',
        style: TextStyle(fontFamily: 'Anemone_air', color: AppColors.darkGray),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 그룹 이름 입력 필드
            TextField(
              controller: _groupNameController,
              style: const TextStyle(fontFamily: 'Anemone_air'),
              decoration: InputDecoration(
                label: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Anemone_air',
                      color: AppColors.darkGray,
                    ),
                    children: [
                      const TextSpan(text: '그룹 이름'),
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: AppColors.red),
                      ),
                    ],
                  ),
                ),
                hintText: '그룹 이름을 입력하세요',
                hintStyle: TextStyle(
                  fontFamily: 'Anemone_air',
                  color: AppColors.mediumGray,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.lightGray),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color:
                        isNameMaxLength ? AppColors.red : AppColors.lightGray,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isNameMaxLength ? AppColors.red : AppColors.primary,
                    width: 2,
                  ),
                ),
                suffixText: '$_nameLength/10',
                suffixStyle: TextStyle(
                  color: isNameMaxLength ? AppColors.red : AppColors.mediumGray,
                  fontFamily: 'Anemone_air',
                ),
                errorText: _isNameEmpty ? '그룹 이름을 입력해주세요' : null,
                errorStyle: TextStyle(
                  color: AppColors.red,
                  fontFamily: 'Anemone_air',
                ),
              ),
              inputFormatters: [LengthLimitingTextInputFormatter(10)],
            ),
            const SizedBox(height: 16),

            // 그룹 설명 입력 필드
            TextField(
              controller: _groupDescriptionController,
              style: const TextStyle(fontFamily: 'Anemone_air'),
              decoration: InputDecoration(
                labelText: '그룹 설명',
                hintText: '그룹을 짧게 설명해주세요  ',
                hintStyle: TextStyle(
                  fontFamily: 'Anemone_air',
                  color: AppColors.mediumGray,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.lightGray),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color:
                        isDescriptionMaxLength
                            ? AppColors.red
                            : AppColors.lightGray,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color:
                        isDescriptionMaxLength
                            ? AppColors.red
                            : AppColors.primary,
                    width: 2,
                  ),
                ),
                suffixText: '$_descriptionLength/20',
                suffixStyle: TextStyle(
                  color:
                      isDescriptionMaxLength
                          ? AppColors.red
                          : AppColors.mediumGray,
                  fontFamily: 'Anemone_air',
                ),
              ),
              maxLines: 3,
              inputFormatters: [LengthLimitingTextInputFormatter(20)],
            ),
            const SizedBox(height: 16),

            // 그룹 공개 여부 스위치
            Row(
              children: [
                Text(
                  '그룹 공개 여부',
                  style: TextStyle(
                    fontFamily: 'Anemone_air',
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(width: 10),
                CustomSwitch(
                  value: _isPublic,
                  onChanged: (bool value) {
                    setState(() {
                      _isPublic = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            '취소',
            style: TextStyle(
              fontFamily: 'Anemone_air',
              color: AppColors.mediumGray,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () {
            String groupName = _groupNameController.text.trim();
            if (groupName.isEmpty) {
              setState(() {
                _isNameEmpty = true;
              });
            } else {
              // GroupProvider를 사용해 그룹 추가
              Provider.of<GroupProvider>(context, listen: false).addGroup(
                name: groupName,
                description: _groupDescriptionController.text.trim(),
                isPublic: _isPublic,
                memberId: 1, // 현재 로그인한 사용자 ID - 실제 구현에서는 로그인 정보에서 가져와야 함
              );
              Navigator.of(context).pop();
            }
          },
          child: Text(
            '생성',
            style: TextStyle(fontFamily: 'Anemone_air', color: Colors.white),
          ),
        ),
      ],
    );
  }
}