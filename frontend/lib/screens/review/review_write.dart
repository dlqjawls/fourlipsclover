import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/review_model.dart';
import '../../services/review_service.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/clover_loading_spinner.dart';

class ReviewWriteScreen extends StatefulWidget {
  final Review? review;
  final String kakaoPlaceId;

  const ReviewWriteScreen({Key? key, this.review, required this.kakaoPlaceId})
      : super(key: key);

  @override
  _ReviewWriteScreenState createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends State<ReviewWriteScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _visitedAtController = TextEditingController();
  DateTime? _visitedAt;
  List<File> newImages = [];
  List<String> existingImages = [];
  List<String> imagesToDelete = [];
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.review != null) {
      _contentController.text = widget.review!.content;
      _visitedAt = widget.review!.date;
      _visitedAtController.text = _formatDate(_visitedAt!);
      existingImages = List.from(widget.review!.imageUrls);
    } else {
      _visitedAt = DateTime.now();
      _visitedAtController.text = _formatDate(_visitedAt!);
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final image = File(pickedFile.path);
      setState(() {
        newImages.add(image); // ✅ 이미지 추가
      });
    }
  }

  void _removeExistingImage(String url) {
    setState(() {
      existingImages.remove(url);
      imagesToDelete.add(url);
    });
  }

  void _removeNewImage(File image) {
    setState(() {
      newImages.remove(image);
    });
  }

  Future<void> _submitReview() async {
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("리뷰 내용을 입력해주세요.")),
      );
      return;
    }

    if (content.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("리뷰는 10자 이상 작성해주세요.")),
      );
      return;
    }

    if (_visitedAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("방문일자를 선택해주세요.")),
      );
      return;
    }


    setState(() => isSubmitting = true);

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final accessToken = appProvider.jwtToken;
      if (accessToken == null) throw Exception("로그인이 필요합니다.");

      if (widget.review == null) {
        final memberId = int.parse(appProvider.user!.id.toString());

        final response = await ReviewService.createReview(
          memberId: memberId,
          kakaoPlaceId: widget.kakaoPlaceId,
          content: content,
          visitedAt: _visitedAt!,
          imageFile: newImages.isNotEmpty ? newImages.first : null,
          accessToken: accessToken,
        );

        final refreshed = await ReviewService.getReviewDetail(
          kakaoPlaceId: widget.kakaoPlaceId,
          reviewId: response.reviewId!,
        );

        final createdReview = Review.fromResponse(refreshed);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("리뷰가 등록되었습니다.")),
        );
        Navigator.pop(context, createdReview);
      } else {
        final updated = await ReviewService.updateReview(
          reviewId: int.parse(widget.review!.id),
          content: content,
          visitedAt: _visitedAt!,
          deleteImageUrls: imagesToDelete,
          newImages: newImages,
          accessToken: accessToken,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("리뷰가 수정되었습니다.")),
        );
        Navigator.pop(context, Review.fromResponse(updated));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류 발생: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.review != null;

    return LoadingOverlay(
      isLoading: isSubmitting,
      overlayColor: Colors.white.withOpacity(0.7),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? "리뷰 수정" : "리뷰 작성"),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _visitedAtController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "방문일자",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _visitedAt ?? DateTime.now(),
                    firstDate: DateTime(2022),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _visitedAt = picked;
                      _visitedAtController.text = _formatDate(picked);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (isEditMode || newImages.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...existingImages.map(
                          (url) => Stack(
                        children: [
                          Image.network(url, width: 100, height: 100, fit: BoxFit.cover),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () => _removeExistingImage(url),
                              child: Icon(Icons.cancel, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...newImages.map(
                          (file) => Stack(
                        children: [
                          Image.file(file, width: 100, height: 100, fit: BoxFit.cover),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () => _removeNewImage(file),
                              child: Icon(Icons.cancel, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        color: AppColors.lightGray,
                        child: Icon(Icons.add_a_photo, color: AppColors.darkGray),
                      ),
                    ),
                  ],
                )
              else
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.lightGray),
                    ),
                    child: Center(
                      child: Text("이미지 선택", style: TextStyle(color: AppColors.darkGray)),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "소중한 의견을 남겨주세요",
                    hintStyle: TextStyle(color: AppColors.mediumGray),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.mediumGray,
                  ),
                  child: Text(
                    isEditMode ? "수정 완료" : "리뷰 저장",
                    style: TextStyle(color: AppColors.verylightGray),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
