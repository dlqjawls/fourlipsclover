import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/review_model.dart';
import '../../services/review_service.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/clover_loading_spinner.dart';
import '../../screens/review/review_list.dart';
import '../../widgets/toast_bar.dart';


class ReviewWriteScreen extends StatefulWidget {
  final Review? review;
  final String kakaoPlaceId;
  final ScrollController? scrollController;
  final String? accessToken;
  final int? memberId;

  const ReviewWriteScreen({
    Key? key,
    this.review,
    required this.kakaoPlaceId,
    this.scrollController,
    this.accessToken,
    this.memberId,
  }) : super(key: key);

  @override
  State<ReviewWriteScreen> createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends State<ReviewWriteScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _visitedAtController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _visitorCountController = TextEditingController();
  DateTime? _visitedAt;
  List<File> newImages = [];
  List<String> existingImages = [];
  List<String> imagesToDelete = [];
  bool isSubmitting = false;
  late final bool isEditMode;

  @override
  void initState() {
    super.initState();
    isEditMode = widget.review != null;
    if (widget.review != null) {
      _contentController.text = widget.review!.content;
      _visitedAt = widget.review!.date;
      _visitedAtController.text = _formatDate(_visitedAt!);
      existingImages = List.from(widget.review!.imageUrls);

      // Initialize with existing data if available
      if (widget.review!.totalAmount != null) {
        _totalAmountController.text = widget.review!.totalAmount.toString();
      }
      if (widget.review!.visitorCount != null) {
        _visitorCountController.text = widget.review!.visitorCount.toString();
      }
    } else {
      _visitedAt = DateTime.now();
      _visitedAtController.text = _formatDate(_visitedAt!);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        newImages.add(File(pickedFile.path));
      });
    }
  }

  void _removeExistingImage(String url) {
    setState(() {
      existingImages.remove(url);
      imagesToDelete.add(url);
    });
  }

  void _removeNewImage(File file) {
    setState(() {
      newImages.remove(file);
    });
  }

  Future<void> _submitReview() async {
    final content = _contentController.text.trim();
    final totalAmountText = _totalAmountController.text.trim();
    final visitorCountText = _visitorCountController.text.trim();

    if (content.isEmpty || content.length < 10) {
        ToastBar.clover('리뷰는 10자 이상 작성해주세요.');
      return;
    }

    if (_visitedAt == null) {
      ToastBar.clover('방문일자를 선택해주세요.');
      return;
    }

    // ✅ 변수 선언을 먼저 함
    int? totalAmount;
    int? visitorCount;

    if (!isEditMode) {
      if (totalAmountText.isEmpty) {
        ToastBar.clover('결제금액을 입력해주세요.');
        return;
      }

      if (visitorCountText.isEmpty) {
        ToastBar.clover('방문인원을 입력해주세요.');
        return;
      }

      totalAmount = int.tryParse(totalAmountText);
      if (totalAmount == null || totalAmount <= 0) {
        ToastBar.clover('유효한 결제금액을 입력해주세요.');
        return;
      }

      visitorCount = int.tryParse(visitorCountText);
      if (visitorCount == null || visitorCount <= 0) {
        ToastBar.clover('유효한 방문인원을 입력해주세요.');
        return;
      }
    }

    setState(() => isSubmitting = true);

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final accessToken = appProvider.jwtToken;
      if (accessToken == null) throw Exception("로그인이 필요합니다.");

      final memberId = int.parse(appProvider.user!.id.toString());

      print('[🧪 리뷰 생성 요청 데이터]');
      print('memberId: $memberId');
      print('accessToken: $accessToken');
      print('kakaoPlaceId: ${widget.kakaoPlaceId}');
      print('content: $content');
      print('visitedAt: $_visitedAt');
      print('amount: $totalAmount');
      print('visitedPersonnel: $visitorCount');
      print('이미지 개수: ${newImages.length}');

      Review? createdOrUpdated;

      if (widget.review == null) {
        final created = await ReviewService.createReview(
          memberId: memberId,
          kakaoPlaceId: widget.kakaoPlaceId,
          content: content,
          visitedAt: _visitedAt!,
          imageFiles: newImages.isNotEmpty ? newImages : null,
          accessToken: accessToken,
          amount: totalAmount!,
          visitedPersonnel: visitorCount!,
        );
        createdOrUpdated = Review.fromResponse(created);
      } else {
        final updated = await ReviewService.updateReview(
          reviewId: int.parse(widget.review!.id),
          content: content,
          visitedAt: _visitedAt!,
          deleteImageUrls: imagesToDelete,
          newImages: newImages,
          accessToken: accessToken,
        );
        createdOrUpdated = Review.fromResponse(updated);
      }

      Navigator.of(context).pop(createdOrUpdated);

    } catch (e) {
      ToastBar.clover('리뷰 작성 중 오류가 발생했습니다.');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? prefix,
    String? suffix,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.darkGray.withOpacity(0.6)),
            fillColor: AppColors.lightGray.withOpacity(0.1),
            filled: true,
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.lightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            prefixText: prefix,
            suffixText: suffix,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingOverlay(
        isLoading: isSubmitting,
        overlayColor: Colors.white.withOpacity(0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle and title bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    isEditMode ? "리뷰 수정" : "리뷰 작성",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content area
            Expanded(
              child: ListView(
                controller: widget.scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  // Visit date section
                  Text(
                    "방문일자",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _visitedAt ?? DateTime.now(),
                        firstDate: DateTime(2022),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.primary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          _visitedAt = picked;
                          _visitedAtController.text = _formatDate(picked);
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightGray),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            _visitedAtController.text,
                            style: theme.textTheme.bodyLarge,
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_drop_down, color: AppColors.darkGray),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Total payment amount
                  if (!isEditMode) ...[
                    _buildInputField(
                      label: "총 결제금액 *",
                      controller: _totalAmountController,
                      hintText: "결제한 총 금액을 입력하세요",
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      suffix: "원",
                    ),
                    _buildInputField(
                      label: "방문인원 *",
                      controller: _visitorCountController,
                      hintText: "함께 방문한 인원 수를 입력하세요",
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      suffix: "명",
                    ),
                  ],

                  // Images section
                  Text(
                    "사진 첨부",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // Add photo button
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.lightGray.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.lightGray,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "사진 추가",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Existing images
                        ...existingImages.map((url) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  url,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: GestureDetector(
                                  onTap: () => _removeExistingImage(url),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),

                        // New images
                        ...newImages.map((file) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  file,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: GestureDetector(
                                  onTap: () => _removeNewImage(file),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Review content section
                  Text(
                    "리뷰 내용",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contentController,
                    maxLines: 8,
                    minLines: 5,
                    decoration: InputDecoration(
                      hintText: "소중한 의견을 남겨주세요 (10자 이상)",
                      hintStyle: TextStyle(color: AppColors.darkGray.withOpacity(0.6)),
                      fillColor: AppColors.lightGray.withOpacity(0.1),
                      filled: true,
                      contentPadding: const EdgeInsets.all(16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.lightGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Submit button
            Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.mediumGray,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isEditMode ? "리뷰 수정" : "리뷰 등록",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}