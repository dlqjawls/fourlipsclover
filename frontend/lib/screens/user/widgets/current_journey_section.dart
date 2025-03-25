import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/user_journey.dart';
import 'package:frontend/screens/user/user_journey.dart';

class CurrentJourneySection extends StatelessWidget {
  final String journey;

  const CurrentJourneySection({
    Key? key, 
    required this.journey
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        onTap: () {
          // 여정 상세 페이지로 이동하는 로직 추가 가능
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.map_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '진행중인 여정',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                journey,
                style: const TextStyle(
                  color: AppColors.darkGray,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}