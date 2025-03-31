import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart'; // ✅ Provider 추가
import '../../models/review_model.dart';
import '../../services/review_service.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart'; // ✅ AppProvider import

class ReviewWriteScreen extends StatefulWidget {
  final Review? review; // 수정할 리뷰 (null이면 새 리뷰 작성)
  final String kakaoPlaceId; // 식당 고유 ID

  const ReviewWriteScreen({Key? key, this.review, required this.kakaoPlaceId})
      : super(key: key);

  @override
  _ReviewWriteScreenState createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends State<ReviewWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _image;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.review != null) {
      _titleController.text = widget.review!.title ?? "";
      _contentController.text = widget.review!.content;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitReview() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("리뷰 내용을 입력해주세요.")),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final accessToken = appProvider.jwtToken;
      if (accessToken == null) {
        throw Exception("로그인이 필요합니다.");
      }

      if (widget.review == null) {
        // ✅ 리뷰 작성
        await ReviewService.createReview(
          memberId: int.parse(appProvider.user!.id.toString()),
          kakaoPlaceId: widget.kakaoPlaceId,
          content: _contentController.text.trim(),
          visitedAt: DateTime.now(),
          imageFile: _image,
          accessToken: accessToken, // ✅ 토큰 전달
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("리뷰가 등록되었습니다.")));
      } else {
        // ✅ 리뷰 수정
        await ReviewService.updateReview(
          reviewId: int.parse(widget.review!.id),
          content: _contentController.text.trim(),
          visitedAt: DateTime.now(),
          accessToken: accessToken,
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("리뷰가 수정되었습니다.")));
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("오류 발생: $e")));
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.review != null;

    return Scaffold(
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
            /// 제목 입력
            TextField(
              controller: _titleController,
              style: TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: "리뷰 제목",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            Container(
              height: 1,
              color: Colors.grey.shade300,
              margin: EdgeInsets.only(bottom: 16),
            ),
            const SizedBox(height: 16),

            /// 이미지 선택 UI (작성 시에만 보이도록)
            if (!isEditMode)
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
                  child: _image != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_image!, fit: BoxFit.cover),
                  )
                      : Center(
                    child: Text("이미지 선택",
                        style: TextStyle(color: AppColors.darkGray)),
                  ),
                ),
              ),

            if (!isEditMode) const SizedBox(height: 16),

            /// 내용 입력
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: "소중한 의견을 남겨주세요",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.mediumGray,
                ),
                child: isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  isEditMode ? "수정 완료" : "리뷰 저장",
                  style: TextStyle(color: AppColors.verylightGray),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
