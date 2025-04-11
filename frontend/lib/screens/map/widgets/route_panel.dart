// lib/screens/map/widgets/route_panel.dart
import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class RoutePanel extends StatelessWidget {
  final String? originName;
  final String? destinationName;
  final VoidCallback onSwapLocations;
  final VoidCallback onClose;

  const RoutePanel({
    Key? key,
    required this.originName,
    required this.destinationName,
    required this.onSwapLocations,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;
    
    return Material(
      color: Colors.white,
      elevation: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상태 표시줄 영역
          SizedBox(height: statusBarHeight),
          
          // 심플한 길찾기 패널
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: onClose,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '출발: ${originName ?? "현재 위치"}',
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '도착: ${destinationName ?? "목적지"}',
                        style: TextStyle(
                          fontFamily: 'Anemone_air',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.swap_vert),
                  onPressed: onSwapLocations,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}