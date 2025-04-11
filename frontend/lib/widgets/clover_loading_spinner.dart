// lib/widgets/clover_loading_spinner.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../config/theme.dart';

// 로딩 스피너 클래스
class CloverLoadingSpinner extends StatelessWidget {
  final double size;

  const CloverLoadingSpinner({Key? key, this.size = 50.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/loading.gif',
        width: size,
        height: size,
      ),
    );
  }
}

// 로딩 상태를 관리하는 확장된 로딩 오버레이 클래스
class LoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final Color overlayColor;
  final Duration minDisplayTime; // 최소 표시 시간 추가

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.overlayColor = AppColors.background,
    this.minDisplayTime = const Duration(milliseconds: 1200), // 기본값 1.2초
  }) : super(key: key);

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  bool _showLoading = false;
  Timer? _timer;
  DateTime? _loadingStartTime;

  @override
  void initState() {
    super.initState();
    _updateLoadingState();
  }

  @override
  void didUpdateWidget(LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 로딩 상태가 변경되면 상태 업데이트
    if (oldWidget.isLoading != widget.isLoading) {
      _updateLoadingState();
    }
  }

  void _updateLoadingState() {
    if (widget.isLoading) {
      // 로딩 시작
      _loadingStartTime = DateTime.now();
      setState(() {
        _showLoading = true;
      });
    } else if (_showLoading) {
      // 로딩 종료 요청
      final loadingElapsed =
          _loadingStartTime != null
              ? DateTime.now().difference(_loadingStartTime!)
              : Duration.zero;

      // 최소 표시 시간이 경과했는지 확인
      if (loadingElapsed >= widget.minDisplayTime) {
        // 최소 시간 충족, 바로 숨김
        setState(() {
          _showLoading = false;
        });
      } else {
        // 최소 시간 미충족, 타이머 설정
        final remainingTime = widget.minDisplayTime - loadingElapsed;
        _timer?.cancel();
        _timer = Timer(remainingTime, () {
          if (mounted) {
            setState(() {
              _showLoading = false;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child, // 기본 컨텐츠
        if (_showLoading)
          Container(
            color: widget.overlayColor,
            width: double.infinity,
            height: double.infinity,
            child: const Center(child: CloverLoadingSpinner(size: 120)),
          ),
      ],
    );
  }
}

// 로딩 관련 Provider
class LoadingProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }
}
