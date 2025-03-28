import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/group_provider.dart';
import '../../../widgets/custom_switch.dart';

class GroupCreateBottomSheet extends StatefulWidget {
  const GroupCreateBottomSheet({Key? key}) : super(key: key);

  @override
  _GroupCreateBottomSheetState createState() => _GroupCreateBottomSheetState();
}

class _GroupCreateBottomSheetState extends State<GroupCreateBottomSheet> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();
  bool _isPublic = false;
  bool _isNameEmpty = false;
  bool _isCreating = false;
  int _nameLength = 0;
  int _descriptionLength = 0;
  bool _isKeyboardVisible = false;

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
    final screenHeight = MediaQuery.of(context).size.height;

    // 키보드가 보이는지 확인
    _isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    // 키보드 상태에 따라 높이 조절
    final maxHeight =
        _isKeyboardVisible ? screenHeight * 0.85 : screenHeight * 0.65;

    return Container(
      padding: EdgeInsets.only(
        top: 8,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      // 키보드 상태에 따라 동적으로 높이 조절
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 드래그 핸들
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 상단 제목 (가운데 정렬)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '그룹 생성',
                style: TextStyle(
                  fontFamily: 'Anemone_air',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 내용 영역
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 그룹 이름 라벨
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Anemone_air',
                        fontSize: 14,
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
                  const SizedBox(height: 8),

                  // 그룹 이름 입력 필드
                  TextField(
                    controller: _groupNameController,
                    style: const TextStyle(fontFamily: 'Anemone_air'),
                    decoration: InputDecoration(
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
                              isNameMaxLength
                                  ? AppColors.red
                                  : AppColors.lightGray,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color:
                              isNameMaxLength
                                  ? AppColors.red
                                  : AppColors.primary,
                          width: 2,
                        ),
                      ),
                      suffixText: '$_nameLength/10',
                      suffixStyle: TextStyle(
                        color:
                            isNameMaxLength
                                ? AppColors.red
                                : AppColors.mediumGray,
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

                  const SizedBox(height: 20),

                  // 그룹 설명 라벨
                  Text(
                    '그룹 설명',
                    style: TextStyle(
                      fontFamily: 'Anemone_air',
                      fontSize: 14,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 그룹 설명 입력 필드
                  TextField(
                    controller: _groupDescriptionController,
                    style: const TextStyle(fontFamily: 'Anemone_air'),
                    decoration: InputDecoration(
                      hintText: '그룹을 짧게 설명해주세요',
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

                  const SizedBox(height: 20),

                  // 그룹 공개 여부 라벨
                  Text(
                    '그룹 공개 여부',
                    style: TextStyle(
                      fontFamily: 'Anemone_air',
                      fontSize: 14,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 그룹 공개 여부 필드 (일반 필드와 유사한 스타일로 변경)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightGray),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isPublic ? '공개' : '비공개',
                          style: TextStyle(
                            fontFamily: 'Anemone_air',
                            color: AppColors.darkGray,
                          ),
                        ),
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
                  ),
                ],
              ),
            ),
          ),

          // 하단 버튼 영역 (생성 버튼만 남기고 크게 만듦)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed:
                    _isCreating
                        ? null
                        : () async {
                          String groupName = _groupNameController.text.trim();
                          if (groupName.isEmpty) {
                            setState(() {
                              _isNameEmpty = true;
                            });
                            return;
                          }

                          setState(() {
                            _isCreating = true;
                          });

                          try {
                            // GroupProvider를 사용해 그룹 추가 API 호출
                            final success = await Provider.of<GroupProvider>(
                              context,
                              listen: false,
                            ).addGroup(
                              name: groupName,
                              description:
                                  _groupDescriptionController.text.trim(),
                              isPublic: _isPublic,
                            );

                            if (success) {
                              // 그룹 목록 새로고침
                              await Provider.of<GroupProvider>(
                                context,
                                listen: false,
                              ).fetchMyGroups();

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '그룹이 생성되었습니다.',
                                      style: TextStyle(
                                        fontFamily: 'Anemone_air',
                                      ),
                                    ),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                                Navigator.of(
                                  context,
                                ).pop(true); // true 반환하여 생성 성공 알림
                              }
                            } else {
                              if (mounted) {
                                final error =
                                    Provider.of<GroupProvider>(
                                      context,
                                      listen: false,
                                    ).error;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      error ?? '그룹 생성에 실패했습니다.',
                                      style: TextStyle(
                                        fontFamily: 'Anemone_air',
                                      ),
                                    ),
                                    backgroundColor: AppColors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '오류가 발생했습니다: $e',
                                    style: TextStyle(fontFamily: 'Anemone_air'),
                                  ),
                                  backgroundColor: AppColors.red,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isCreating = false;
                              });
                            }
                          }
                        },
                child:
                    _isCreating
                        ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          '그룹 생성',
                          style: TextStyle(
                            fontFamily: 'Anemone_air',
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
