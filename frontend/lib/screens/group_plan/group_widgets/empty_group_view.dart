import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class EmptyGroupView extends StatelessWidget {
  final VoidCallback onCreateGroup;

  const EmptyGroupView({Key? key, required this.onCreateGroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
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
                    style: const TextStyle(
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
                  onTap: onCreateGroup,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.verylightGray,
                      border: Border.all(color: AppColors.primary, width: 2.0),
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
                        color: AppColors.primary,
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
    );
  }
}