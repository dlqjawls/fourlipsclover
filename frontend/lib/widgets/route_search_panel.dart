// lib/widgets/route_search_panel.dart
import 'package:flutter/material.dart';
import '../config/theme.dart';

class RouteSearchPanel extends StatefulWidget {
  final String? originName;
  final String? destinationName;
  final VoidCallback? onSwapLocations;
  final VoidCallback? onOriginTap;
  final VoidCallback? onDestinationTap;
  final VoidCallback? onAddWaypoint;
  final VoidCallback? onClose;
  final VoidCallback? onSearch;
  
  const RouteSearchPanel({
    Key? key,
    this.originName,
    this.destinationName,
    this.onSwapLocations,
    this.onOriginTap,
    this.onDestinationTap,
    this.onAddWaypoint,
    this.onClose,
    this.onSearch,
  }) : super(key: key);
  
  @override
  State<RouteSearchPanel> createState() => _RouteSearchPanelState();
}

class _RouteSearchPanelState extends State<RouteSearchPanel> {
  String? _prevOriginName;
  String? _prevDestinationName;

  @override
  void didUpdateWidget(RouteSearchPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 출발지와 도착지가 모두 설정되었고, 이전과 달라졌다면 검색 실행
    if (widget.originName != null && 
        widget.destinationName != null &&
        (widget.originName != _prevOriginName || 
         widget.destinationName != _prevDestinationName)) {
      
      // 이전 값 업데이트
      _prevOriginName = widget.originName;
      _prevDestinationName = widget.destinationName;
      
      // 자동 검색 실행
      if (widget.onSearch != null) {
        widget.onSearch!();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 출발지 입력 필드
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: Icon(Icons.location_on, color: Colors.white, size: 16),
              ),
              SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: widget.onOriginTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                    ),
                    child: Text(
                      widget.originName ?? '출발지',
                      style: TextStyle(
                        color: widget.originName != null ? Colors.black : Colors.grey[600],
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              if (widget.originName != null && widget.destinationName != null) 
                IconButton(
                  icon: Icon(Icons.swap_vert, color: AppColors.primary),
                  onPressed: widget.onSwapLocations,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          
          SizedBox(height: 8),
          
          // 도착지 입력 필드
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: Icon(Icons.location_on, color: Colors.white, size: 16),
              ),
              SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: widget.onDestinationTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      widget.destinationName ?? '도착지',
                      style: TextStyle(
                        color: widget.destinationName != null ? Colors.black : Colors.grey[600],
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: AppColors.primary),
                onPressed: widget.onAddWaypoint,
                tooltip: '경유지 추가',
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // 입구 검색/닫기 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 닫기 버튼
              IconButton(
                icon: Icon(Icons.close, color: AppColors.darkGray),
                onPressed: widget.onClose,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
              
              // 검색 상태 표시 (길찾기 버튼 대신)
              if (widget.originName != null && widget.destinationName != null) 
                Text(
                  '경로 검색 중...',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                Text(
                  '출발지와 도착지를 모두 설정해주세요',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}