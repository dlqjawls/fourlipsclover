import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../widgets/custom_switch.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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

          // 콘텐츠
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 화면 가운데보다 살짝 위에 배치
                Transform.translate(
                  offset: const Offset(0, -70),
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'Anemone_air',
                            fontSize: 40,
                          ),
                          children: [
                            TextSpan(
                              text: '그룹 ',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '을 추가해주세요',
                              style: TextStyle(
                                color: AppColors.mediumGray,
                                fontSize: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30), // 텍스트와 버튼 사이 간격
                      GestureDetector(
                        onTap: () => _showGroupCreateDialog(context),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 그룹 생성 다이얼로그
  void _showGroupCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _GroupCreateDialog();
      },
    );
  }
}

// 그룹 생성 다이얼로그를 StatefulWidget으로 분리
class _GroupCreateDialog extends StatefulWidget {
  @override
  _GroupCreateDialogState createState() => _GroupCreateDialogState();
}

class _GroupCreateDialogState extends State<_GroupCreateDialog> {
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
              // TODO: Provider를 사용해 그룹 추가 로직 구현
              // 예시: Provider.of<GroupProvider>(context, listen: false).addGroup(
              //   name: groupName,
              //   description: _groupDescriptionController.text.trim(),
              //   isPublic: _isPublic
              // );
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
