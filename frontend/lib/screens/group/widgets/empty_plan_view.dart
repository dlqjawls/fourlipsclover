import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class EmptyPlanView extends StatelessWidget {
  final VoidCallback onAddPlan;
  
  const EmptyPlanView({Key? key, required this.onAddPlan}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight_takeoff,
            size: 72,
            color: AppColors.lightGray,
          ),
          const SizedBox(height: 16),
          Text(
            '여행 계획이 없어요',
            style: TextStyle(
              fontFamily: 'Anemone_air',
              fontSize: 24,
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '새로운 여행을 계획해보세요',
            style: TextStyle(
              fontFamily: 'Anemone_air',
              fontSize: 16,
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onAddPlan,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.verylightGray,
                border: Border.all(color: AppColors.primary, width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}