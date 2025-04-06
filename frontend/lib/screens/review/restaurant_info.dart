import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'dart:math';

class RestaurantInfo extends StatefulWidget {
  final dynamic data; // RestaurantResponse 타입
  final String? imageUrl;

  const RestaurantInfo({
    Key? key,
    required this.data,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<RestaurantInfo> createState() => _RestaurantInfoState();
}

class _RestaurantInfoState extends State<RestaurantInfo> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final openingHours = Map<String, String>.from(widget.data.openingHours ?? {});
    final restaurantImages = widget.data.restaurantImages ?? [];
    final tags = widget.data.tags ?? [];
    final now = DateTime.now();
    final weekdayIndex = now.weekday - 1;
    final todayEng = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"][weekdayIndex];
    final todayRaw = openingHours[todayEng]?.toLowerCase().trim() ?? '';
    final hasOpeningInfo = todayRaw.isNotEmpty && todayRaw != "closed";



    final filteredImages = restaurantImages.where((url) => url != widget.imageUrl).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ✅ 대표 + 서브 이미지
        _buildImageLayout(widget.imageUrl, filteredImages),

        /// ✅ 태그
        /// ✅ 태그
        if (tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 1.0,
              children: tags.map<Widget>((tag) {
                final tagName = tag['tagName']?.toString().replaceAll(' ', '') ?? '';
                return Chip(
                  label: Text(
                    '#$tagName',
                    style: const TextStyle(fontSize: 12, color: AppColors.primaryDark),
                  ),
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  shape: const StadiumBorder(),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          )
        else
          const SizedBox(height: 4), // 태그 없을 때 이미지와 영업시간 사이 여백 보정


        /// ✅ 영업시간 요약 + 전체 보기 토글
        Padding(
          padding: EdgeInsets.fromLTRB(16, tags.isNotEmpty ? 4 : 8, 16, hasOpeningInfo && !_isExpanded ? 0 : 0),
          child: _buildOpeningStatus(openingHours),
        ),

        /// ✅ 전체 영업시간 보기
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildOpeningHoursList(openingHours),
            ),
          ),

        /// ✅ 기본 정보
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.location_on, widget.data.addressName ?? "주소 정보 없음"),
              _buildInfoRow(
                Icons.phone,
                (widget.data.phone != null && widget.data.phone.toString().trim().isNotEmpty)
                    ? widget.data.phone
                    : "전화 번호: 정보 없음",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageLayout(String? mainUrl, List<String> subUrls) {
    final allImages = [if (mainUrl != null) mainUrl, ...subUrls];

    if (allImages.isEmpty) {
      return Image.asset(
        "assets/images/rice.png",
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
      );
    } else if (allImages.length == 1) {
      return GestureDetector(
        onTap: () => _showImageDialog(context, allImages[0]),
        child: Image.network(
          allImages[0],
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset("assets/images/rice.png", width: double.infinity, height: 200, fit: BoxFit.cover);
          },
        ),
      );
    } else if (allImages.length == 2) {
      return Row(
        children: allImages.map((url) {
          return Expanded(
            child: GestureDetector(
              onTap: () => _showImageDialog(context, url),
              child: Container(
                height: 200,
                margin: const EdgeInsets.all(4),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset("assets/images/rice.png", fit: BoxFit.cover);
                  },
                ),
              ),
            ),
          );
        }).toList(),
      );
    } else {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _showImageDialog(context, allImages[0]),
              child: Container(
                height: 200,
                margin: const EdgeInsets.all(4),
                child: Image.network(
                  allImages[0],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset("assets/images/rice.png", fit: BoxFit.cover);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [1, 2].where((i) => i < allImages.length).map((i) {
                return SizedBox(
                  height: 97, // (200 - margin * 2) / 2
                  child: GestureDetector(
                    onTap: () => _showImageDialog(context, allImages[i]),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(allImages[i]),
                          fit: BoxFit.cover,
                          onError: (_, __) {},
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      );
    }
  }

  Widget _buildOpeningStatus(Map<String, String> hours) {
    final now = DateTime.now();
    final weekdayIndex = now.weekday - 1;
    final todayEng = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"][weekdayIndex];
    final tomorrowEng = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"][(weekdayIndex + 1) % 7];

    final todayRaw = hours[todayEng]?.toLowerCase().trim();
    final tomorrowRaw = hours[tomorrowEng]?.trim();

    String displayText;
    Color textColor = AppColors.darkGray;
    bool showToggle = false;

    if (todayRaw == null || todayRaw.isEmpty) {
      displayText = "영업시간: 정보 없음";
    } else if (todayRaw.contains("closed")) {
      final tomorrowTimeMatch = RegExp(r'(\d{1,2}:\d{2})').firstMatch(tomorrowRaw ?? '');
      final openTime = tomorrowTimeMatch?.group(1) ?? "정보 없음";
      displayText = "휴무일 · 내일 $openTime 부터";
      textColor = Colors.red;
      showToggle = true;
    } else {
      final endTimeMatch = RegExp(r'(\d{1,2}:\d{2})\s*(?:~|-)?\s*(\d{1,2}:\d{2})').firstMatch(todayRaw);
      final closeTime = endTimeMatch?.group(2);
      displayText = closeTime != null ? "영업 중 · $closeTime 까지" : "영업 중";
      showToggle = true;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 18, color: AppColors.mediumGray),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayText,
              style: TextStyle(fontSize: 14, color: textColor),
            ),
          ),
          if (showToggle)
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4), // 살짝 여백만 유지
                child: Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.mediumGray,
                ),
              ),
            ),
        ],
      ),
    );
  }



  List<Widget> _buildOpeningHoursList(Map<String, String> hours) {
    final korDays = ['월', '화', '수', '목', '금', '토', '일'];
    final engDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final todayIndex = DateTime.now().weekday - 1;

    return List.generate(7, (i) {
      final dayKor = korDays[i];
      final rawTime = hours[engDays[i]] ?? '정보 없음';
      final time = rawTime.toLowerCase().trim() == 'closed' ? '휴무일' : rawTime;
      final isToday = i == todayIndex;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.5),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: isToday ? '$dayKor요일(오늘): ' : '$dayKor요일: ',
                style: TextStyle(
                  color: isToday ? AppColors.primaryDark : AppColors.darkGray,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
              TextSpan(
                text: time,
                style: const TextStyle(fontSize: 13, color: AppColors.darkGray),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.mediumGray),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.darkGray, fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String? url) {
    if (url == null || url.isEmpty) return;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, size: 48),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}