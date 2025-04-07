import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import '../../../../models/user_model.dart';

class PlanSection extends StatelessWidget {
  final List<PlanResponse> plans;

  const PlanSection({super.key, required this.plans});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '내 계획',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          ...plans.map((plan) => PlanCard(plan: plan)).toList(),
        ],
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  final PlanResponse plan;

  const PlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.verylightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            plan.description,
            style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
          ),
          const SizedBox(height: 8),
          Text(
            '${plan.startDate.toString().split(' ')[0]} ~ ${plan.endDate.toString().split(' ')[0]}',
            style: TextStyle(fontSize: 12, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
