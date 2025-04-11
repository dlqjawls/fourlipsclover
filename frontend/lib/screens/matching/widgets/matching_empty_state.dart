import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

class MatchingEmptyState extends StatelessWidget {
  final VoidCallback onCreateMatch;

  const MatchingEmptyState({Key? key, required this.onCreateMatch})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '아직 매칭 내역이 없습니다',
                    style: TextStyle(fontSize: 16, color: AppColors.mediumGray),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onCreateMatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '새로운 매칭 만들기',
                      style: TextStyle(fontSize: 16, color: Colors.white),
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
}
