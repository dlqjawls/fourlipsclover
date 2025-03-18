import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 우측 하단에 배경 이미지
          Positioned(
            bottom: -100,
            right: -100,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/images/logo.png',
                width: 500,
                height: 500,
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
                  offset: const Offset(0, -50),
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'Anemone_air',
                            fontSize: 36,
                          ),
                          children: [
                            TextSpan(
                              text: '그룹',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '을 추가해주세요',
                              style: TextStyle(
                                color: AppColors.mediumGray,
                                fontSize: 28, // 폰트 크기 조금 줄임
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20), // 텍스트와 버튼 사이 간격
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
    final TextEditingController groupNameController = TextEditingController();
    final TextEditingController groupDescriptionController =
        TextEditingController();
    ValueNotifier<bool> isPublicNotifier = ValueNotifier<bool>(false);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              '새 그룹 생성',
              style: TextStyle(
                fontFamily: 'Anemone_air',
                color: AppColors.darkGray,
              ),
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: groupNameController,
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
                      hintText: '그룹 이름을 입력하세요 (최대 10자)',
                      hintStyle: TextStyle(
                        fontFamily: 'Anemone_air',
                        color: AppColors.mediumGray,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.lightGray),
                      ),
                    ),
                    inputFormatters: [LengthLimitingTextInputFormatter(10)],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: groupDescriptionController,
                    style: const TextStyle(fontFamily: 'Anemone_air'),
                    decoration: InputDecoration(
                      labelText: '그룹 설명',
                      hintText: '그룹에 대한 설명을 입력하세요 (최대 20자)',
                      hintStyle: TextStyle(
                        fontFamily: 'Anemone_air',
                        color: AppColors.mediumGray,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.lightGray),
                      ),
                    ),
                    maxLines: 3,
                    inputFormatters: [LengthLimitingTextInputFormatter(20)],
                  ),
                  const SizedBox(height: 16),
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
                      ValueListenableBuilder<bool>(
                        valueListenable: isPublicNotifier,
                        builder:
                            (context, isPublic, child) => Switch(
                              value: isPublic,
                              onChanged: (bool value) {
                                isPublicNotifier.value = value;
                              },
                              activeColor: AppColors.darkGray,
                              activeTrackColor: AppColors.lightGray,
                              inactiveThumbColor: AppColors.mediumGray,
                              inactiveTrackColor: AppColors.verylightGray,
                            ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                onPressed: () {
                  String groupName = groupNameController.text.trim();
                  if (groupName.isNotEmpty) {
                    // TODO: Provider를 사용해 그룹 추가 로직 구현
                    // 예시: Provider.of<GroupProvider>(context, listen: false).addGroup(
                    //   name: groupName,
                    //   description: groupDescriptionController.text.trim(),
                    //   isPublic: isPublicNotifier.value
                    // );
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  '생성',
                  style: TextStyle(
                    fontFamily: 'Anemone_air',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
