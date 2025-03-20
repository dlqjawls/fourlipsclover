import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../models/review_model.dart'; // Review 모델 import

class ReviewWriteScreen extends StatefulWidget {
  final Review? review; // 수정할 리뷰 (null이면 새 리뷰 작성)

  const ReviewWriteScreen({Key? key, this.review}) : super(key: key);

  @override
  _ReviewWriteScreenState createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends State<ReviewWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _image; // 업로드한 이미지 파일 저장

  @override
  void initState() {
    super.initState();
    if (widget.review != null) {
      // 수정 모드: 기존 데이터 불러오기
      _titleController.text = widget.review!.title ?? "";
      _contentController.text = widget.review!.content;
      if (widget.review!.imageUrl != null) {
        _image = File(widget.review!.imageUrl!); // 기존 이미지 로드
      }
    }
  }

  /// 이미지 선택 함수
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.review != null; // 수정 모드인지 확인

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "리뷰 수정" : "리뷰 작성"), // 수정 모드일 경우 "리뷰 수정"
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
              height: 1, // ✅ 선 두께 설정
              color: Colors.grey.shade300, // ✅ 연한 회색 선
              margin: EdgeInsets.only(bottom: 16), // ✅ 다음 요소와 간격 조정
            ),
            const SizedBox(height: 16),

            /// 사진 추가 공간
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
                  child: Text("이미지 선택", style: TextStyle(color: AppColors.darkGray)),
                ),
              ),
            ),
            const SizedBox(height: 16),

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

            /// 리뷰 저장 버튼 (신규 작성 vs 수정)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (isEditMode) {
                    print("리뷰 수정 완료: 제목=${_titleController.text}, 내용=${_contentController.text}, 이미지=${_image?.path}");
                  } else {
                    print("리뷰 저장: 제목=${_titleController.text}, 내용=${_contentController.text}, 이미지=${_image?.path}");
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text(isEditMode ? "수정 완료" : "리뷰 저장", style: TextStyle(color: AppColors.verylightGray)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
