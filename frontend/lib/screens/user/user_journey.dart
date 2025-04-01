import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

class UserJourneyScreen extends StatelessWidget {
  const UserJourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verylightGray,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkGray),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          '진행중인 여정',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGray,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '2박 3일 중 첫째 날',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  calendarWidget(),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: journeyTimeline(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget calendarWidget() {
    List<int> days = List.generate(14, (index) => 15 + index);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '2025년 3월',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
            children:
                days.map((day) {
                  bool isSelected = day >= 18 && day <= 20;
                  bool isToday = day == 18;
                  return Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primary
                                : AppColors.lightGray,
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            color:
                                isSelected ? Colors.white : AppColors.darkGray,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isToday)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryDark,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.star,
                                size: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget timelineItem(
    String time,
    String title,
    String details, {
    bool completed = false,
    bool current = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    completed
                        ? Icons.check_circle
                        : current
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: completed ? AppColors.mediumGray : AppColors.primary,
                    size: 24,
                  ),
                ],
              ),
              Container(
                width: 2,
                height: 70,
                color:
                    completed || current
                        ? AppColors.primary
                        : AppColors.lightGray,
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: current ? AppColors.verylightGray : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border:
                    current
                        ? Border.all(color: AppColors.primary, width: 1)
                        : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color:
                          completed
                              ? AppColors.mediumGray
                              : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: completed ? AppColors.mediumGray : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    details,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          completed ? AppColors.mediumGray : AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget journeyTimeline() {
    return Column(
      children: [
        timelineItem(
          '08:00 AM',
          '아침 식사',
          '식당 근처 공원 산책\n이후 일정 자율',
          completed: true,
        ),
        timelineItem(
          '09:00 AM',
          '아침 식사',
          '식당 근처 공원 산책\n이후 일정 자율',
          current: true,
        ),
        timelineItem('10:00 AM', '일정', '카페나 갈까?'),
        timelineItem('12:00 PM', '점심 식사', '식당 근처 공원 산책\n이후 일정 자율'),
      ],
    );
  }
}
