// lib/widgets/route_search_panel.dart의 수정된 버전
import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class RouteSearchPanel extends StatefulWidget {
  final String? originName;
  final String? destinationName;
  final VoidCallback? onSwapLocations;
  final VoidCallback? onOriginTap;
  final VoidCallback? onDestinationTap;
  final VoidCallback? onAddWaypoint;
  final VoidCallback? onClose;
  final VoidCallback? onSearch;
  final VoidCallback? onReset;

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
    this.onReset,
  }) : super(key: key);

  @override
  State<RouteSearchPanel> createState() => _RouteSearchPanelState();
}

class _RouteSearchPanelState extends State<RouteSearchPanel> {
  String? _prevOriginName;
  String? _prevDestinationName;
  TransportMode _selectedMode = TransportMode.car;

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
      // 모든 외부 마진 제거하여 상단과 자연스럽게 연결
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        // 그림자 제거하여 전체적으로 깔끔한 느낌으로
        boxShadow: [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 내부 박스
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                // 출발지 입력 필드
                Row(
                  children: [
                    // 위치 바꾸기 버튼을 위한 고정 영역
                    Container(
                      width: 24,
                      height: 24,
                      child:
                          widget.originName != null &&
                                  widget.destinationName != null
                              ? IconButton(
                                icon: Icon(
                                  Icons.swap_vert,
                                  color: AppColors.mediumGray,
                                  size: 20,
                                ),
                                onPressed: widget.onSwapLocations,
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                visualDensity: VisualDensity.compact,
                              )
                              : null,
                    ),

                    SizedBox(width: 8),

                    // 출발지 동심원 아이콘
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: GestureDetector(
                        onTap: widget.onOriginTap,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            widget.originName ?? '출발지',
                            style: TextStyle(
                              color:
                                  widget.originName != null
                                      ? Colors.black
                                      : Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),

                    // 초기화 버튼 (X)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColors.mediumGray,
                        size: 20,
                      ),
                      onPressed: widget.onReset,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),

                // 출발지와 도착지 사이 간격
                SizedBox(height: 10),

                // 도착지 입력 필드
                Row(
                  children: [
                    // 위치 바꾸기 버튼과 동일한 너비의 빈 공간
                    SizedBox(width: 24),

                    SizedBox(width: 8),

                    // 도착지 동심원 아이콘
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.5),
                          ),
                        ),
                      ),
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
                              color:
                                  widget.destinationName != null
                                      ? Colors.black
                                      : Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),

                    // X 버튼 자리와 균형을 맞추기 위한 빈 공간
                    SizedBox(width: 24),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          // 교통수단 선택 아이콘
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTransportButton(
                TransportMode.transit,
                Icons.directions_transit,
                true,
              ),
              _buildTransportButton(
                TransportMode.car,
                Icons.directions_car,
                false,
              ),
              _buildTransportButton(
                TransportMode.walk,
                Icons.directions_walk,
                true,
              ),
              _buildTransportButton(
                TransportMode.bike,
                Icons.directions_bike,
                true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransportButton(
    TransportMode mode,
    IconData icon,
    bool disabled,
  ) {
    return InkWell(
      onTap:
          disabled
              ? null
              : () {
                setState(() {
                  _selectedMode = mode;
                });
              },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        decoration: BoxDecoration(
          color:
              _selectedMode == mode && !disabled
                  ? AppColors.primary
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color:
              disabled
                  ? Colors.grey[400]
                  : _selectedMode == mode && !disabled
                  ? Colors.white
                  : Colors.grey[600],
          size: 22,
        ),
      ),
    );
  }
}

enum TransportMode { transit, car, walk, bike }
