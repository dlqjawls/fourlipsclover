import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:frontend/services/user_service.dart';

class ProfileImageSection extends StatefulWidget {
  final String userId; // int에서 String으로 변경
  final String? initialImageUrl;

  const ProfileImageSection({
    super.key,
    required this.userId,
    this.initialImageUrl,
  });

  @override
  State<ProfileImageSection> createState() => _ProfileImageSectionState();
}

class _ProfileImageSectionState extends State<ProfileImageSection> {
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final userService = Provider.of<UserService>(context, listen: false);

    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isLoading = true);

      final newImageUrl = await userService.uploadProfileImage(
        widget.userId,
        image.path,
      );

      setState(() {
        _imageUrl = newImageUrl;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('이미지 업로드 중 오류가 발생했습니다.')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.lightGray,
          ),
          child: ClipOval(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _imageUrl != null
                    ? Image.network(
                      _imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Icons.person, size: 80),
                    )
                    : const Icon(Icons.person, size: 80),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _uploadImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('프로필 사진 변경'),
        ),
      ],
    );
  }
}
