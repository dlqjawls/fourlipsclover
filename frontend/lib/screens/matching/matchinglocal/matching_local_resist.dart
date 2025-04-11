import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

class MatchingLocalResistScreen extends StatefulWidget {
  final Map<String, dynamic> request;
  final bool isEditing;

  const MatchingLocalResistScreen({
    Key? key,
    required this.request,
    required this.isEditing,
  }) : super(key: key);

  @override
  State<MatchingLocalResistScreen> createState() =>
      _MatchingLocalResistScreenState();
}

class _MatchingLocalResistScreenState extends State<MatchingLocalResistScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placeController = TextEditingController();
  final _menuController = TextEditingController();
  final _reviewLinkController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _placeController.dispose();
    _menuController.dispose();
    _reviewLinkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('기획서 작성'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkGray),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRequestInfo(),
                const SizedBox(height: 24),
                _buildInputField(
                  label: '추천 장소',
                  hint: '방문할 장소를 입력해주세요',
                  controller: _placeController,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: '추천 메뉴',
                  hint: '추천하는 메뉴를 입력해주세요',
                  controller: _menuController,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: '리뷰 링크',
                  hint: '관련 리뷰 링크를 입력해주세요',
                  controller: _reviewLinkController,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: '기타 사항',
                  hint: '추가로 전달할 내용을 입력해주세요',
                  controller: _notesController,
                  maxLines: 5,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '기획서 제출하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.request['name']}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '시작 일시: ${widget.request['startDate']}',
            style: const TextStyle(fontSize: 14, color: AppColors.mediumGray),
          ),
          Text(
            '종료 일시: ${widget.request['endDate']}',
            style: const TextStyle(fontSize: 14, color: AppColors.mediumGray),
          ),
          Text(
            '팁: ${widget.request['tip']}원',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.mediumGray.withOpacity(0.5),
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.mediumGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.mediumGray.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label을(를) 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: API 호출 및 데이터 저장 로직 구현
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? '기획서가 수정되었습니다' : '기획서가 제출되었습니다'),
        ),
      );
      Navigator.pop(context, true); // true를 반환하여 기획서 작성/수정 완료를 알림
    }
  }
}
