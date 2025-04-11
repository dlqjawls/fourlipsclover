import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/review_model.dart';

class ReviewPhotoGallery extends StatefulWidget {
  final Review review;
  final int initialIndex;

  const ReviewPhotoGallery({
    Key? key,
    required this.review,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<ReviewPhotoGallery> createState() => _ReviewPhotoGalleryState();
}

class _ReviewPhotoGalleryState extends State<ReviewPhotoGallery> {
  late int currentIndex;
  late PageController _pageController;
  final Map<int, TransformationController> _transformationControllers = {};
  bool _canChangePage = true;
  bool _showZoomHint = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);

    if (widget.review.imageUrls != null) {
      for (int i = 0; i < widget.review.imageUrls!.length; i++) {
        _transformationControllers[i] = TransformationController();

        _transformationControllers[i]!.addListener(() {
          final controller = _transformationControllers[i]!;
          final scale = controller.value.getMaxScaleOnAxis();

          // 스케일이 1.0에 가까우면 페이지 전환 가능
          final canChangePage = scale <= 1.05;
          if (_canChangePage != canChangePage) {
            setState(() {
              _canChangePage = canChangePage;
            });
          }
        });
      }
    }

    // 3초 후 줌 힌트 숨기기
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showZoomHint = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _resetZoom() {
    if (_transformationControllers.containsKey(currentIndex)) {
      _transformationControllers[currentIndex]!.value = Matrix4.identity();
    }
    _canChangePage = true;
  }

  ImageProvider _buildProfileImageProvider(String? imageUrl) {
    final baseUrl = dotenv.env['API_BASE_URL'];
    if (imageUrl == null || imageUrl.isEmpty) {
      return const AssetImage('assets/default_profile.png');
    } else if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    } else if (imageUrl.startsWith('assets/')) {
      return AssetImage(imageUrl);
    } else {
      return NetworkImage('$baseUrl/uploads/profile/$imageUrl');
    }
  }

  String _formatDate(DateTime date) {
    return "${date.month}.${date.day}";
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.review.imageUrls;
    if (images == null || images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            physics: _canChangePage
                ? const PageScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
                _resetZoom();
              });
            },
            itemBuilder: (context, index) {
              final transformationController = _transformationControllers[index] ?? TransformationController();

              return LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: InteractiveViewer(
                          transformationController: transformationController,
                          minScale: 1.0,
                          maxScale: 3.0, // 최대 확대 배율 감소
                          constrained: true, // 중요: 경계 제약 활성화
                          clipBehavior: Clip.none, // 클리핑 없음
                          panEnabled: true, // 패닝 활성화
                          scaleEnabled: true, // 스케일 활성화
                          boundaryMargin: const EdgeInsets.all(0), // 경계 여백 없음 - 사진이 화면 밖으로 나가지 않도록
                          child: Center(
                            child: Image(
                              image: images[index].startsWith("http")
                                  ? NetworkImage(images[index])
                                  : AssetImage(images[index]) as ImageProvider,
                              fit: BoxFit.contain,
                            ),
                          ),
                          onInteractionEnd: (details) {
                            final scale = transformationController.value.getMaxScaleOnAxis();
                            if (scale <= 1.05) {
                              setState(() {
                                _canChangePage = true;
                              });
                            }
                          },
                        ),
                      ),

                      // 더블 탭으로 확대/축소
                      Positioned.fill(
                        child: GestureDetector(
                          onDoubleTap: () {
                            final scale = transformationController.value.getMaxScaleOnAxis();
                            if (scale > 1.05) {
                              // 원래 크기로 복원
                              transformationController.value = Matrix4.identity();
                              setState(() {
                                _canChangePage = true;
                              });
                            } else {
                              // 2배로 확대 (이전보다 덜 민감하게)
                              transformationController.value = Matrix4.identity()..scale(1.8);
                              setState(() {
                                _canChangePage = false;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          // 상단바
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 뒤로가기 버튼
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),

                      // 이미지 카운터
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "${currentIndex + 1} / ${images.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 프로필 정보와 리뷰 내용
                AnimatedOpacity(
                  opacity: _canChangePage ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: _buildProfileImageProvider(widget.review.profileImageUrl),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.review.username,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      "${widget.review.visitCount}번째 방문 | ${_formatDate(widget.review.date)}",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (widget.review.content.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                              child: AnimatedCrossFade(
                                firstChild: Text(
                                  widget.review.content,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                secondChild: SingleChildScrollView(
                                  child: Text(
                                    widget.review.content,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                crossFadeState: _isExpanded
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 200),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 이전/다음 버튼
          if (_canChangePage) ...[
            if (currentIndex > 0)
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),

            if (currentIndex < images.length - 1)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
          // // 안내 팝업 (시작 시 잠시 표시)
          // if (_showZoomHint)
          //   Positioned(
          //     bottom: 20,
          //     left: 0,
          //     right: 0,
          //     child: Center(
          //       child: Container(
          //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //         decoration: BoxDecoration(
          //           color: Colors.black.withOpacity(0.6),
          //           borderRadius: BorderRadius.circular(20),
          //         ),
          //         child: const Text(
          //           "두 손가락으로 확대/축소하거나 더블탭하세요",
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontSize: 12,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}