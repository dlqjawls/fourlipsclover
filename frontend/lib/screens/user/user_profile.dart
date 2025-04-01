import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/screens/user/profile_widgets/consumption_chart.dart';
import 'package:frontend/screens/user/profile_widgets/badge_section.dart';
import 'package:frontend/screens/user/profile_widgets/keyword_section.dart';
import 'package:frontend/screens/user/profile_widgets/attendance_section.dart';
import 'package:frontend/screens/user/profile_widgets/most_visited_section.dart';

class MyConsumptionPatternScreen extends StatelessWidget {
  const MyConsumptionPatternScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verylightGray,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('나의 프로필'),
        centerTitle: true,
        backgroundColor: AppColors.verylightGray,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ConsumptionChart(),
            SizedBox(height: 32),
            BadgeSection(),
            SizedBox(height: 32),
            KeywordSection(),
            SizedBox(height: 32),
            AttendanceSection(),
            SizedBox(height: 32),
            MostVisitedSection(),
          ],
        ),
      ),
    );
  }
}
