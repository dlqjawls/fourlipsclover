// lib/screens/map/widgets/map_controller.dart
import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class MapController extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onCurrentLocation;

  const MapController({
    Key? key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onCurrentLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 줌 컨트롤 버튼
        Positioned(
          right: 16,
          bottom: 80,
          child: Column(
            children: [
              // 줌 인 버튼
              FloatingActionButton(
                mini: true,
                heroTag: 'zoomIn',
                backgroundColor: Colors.white,
                foregroundColor: AppColors.darkGray,
                child: Icon(Icons.add),
                onPressed: onZoomIn,
              ),
              SizedBox(height: 8),
              // 줌 아웃 버튼
              FloatingActionButton(
                mini: true,
                heroTag: 'zoomOut',
                backgroundColor: Colors.white,
                foregroundColor: AppColors.darkGray,
                child: Icon(Icons.remove),
                onPressed: onZoomOut,
              ),
            ],
          ),
        ),

        // 현재 위치 버튼
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            child: Icon(Icons.my_location),
            onPressed: onCurrentLocation,
          ),
        ),
      ],
    );
  }
}