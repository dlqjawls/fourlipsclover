// lib/widgets/route_summary_modal.dart
import 'package:flutter/material.dart';
import '../models/route_model.dart';
import '../config/theme.dart';

class RouteSummaryModal extends StatelessWidget {
  final KakaoRoute route;

  const RouteSummaryModal({Key? key, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 총 거리 계산 (km 단위)
    final distance = (route.summary.distance / 1000).toStringAsFixed(1);

    // 소요 시간 계산 (분 단위, 필요시 시간+분으로 변환)
    final durationMinutes = (route.summary.duration / 60).ceil();
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    final durationText = hours > 0 ? '$hours시간 $minutes분' : '$minutes분';

    // 택시 요금 포맷팅 (천 단위 콤마)
    final taxiFare = route.summary.fare.taxi.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // "큰길 우선" 표시
            Text(
              '큰길 우선',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),

            SizedBox(height: 8),

            // 시간 및 거리 정보
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 시간 (크게, 초록색)
                Text(
                  durationText,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                // 거리 (중간 크기, 검정색)
                Text(
                  '$distance km',
                  style: TextStyle(color: AppColors.darkGray, fontSize: 16),
                ),
              ],
            ),

            SizedBox(height: 12),

            // 택시 요금 정보
            Row(
              children: [
                Icon(Icons.local_taxi, size: 16, color: AppColors.mediumGray),
                SizedBox(width: 4),
                Text(
                  '택시비 약',
                  style: TextStyle(color: AppColors.mediumGray, fontSize: 14),
                ),
                SizedBox(width: 4),
                Text(
                  '$taxiFare원',
                  style: TextStyle(
                    color: AppColors.mediumGray,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
