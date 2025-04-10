import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../config/theme.dart';
import '../../../../screens/user/user_authorization.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../services/user_service.dart';

class CloverProfileSection extends StatefulWidget {
  final UserProfile profile;

  const CloverProfileSection({super.key, required this.profile});

  @override
  State<CloverProfileSection> createState() => _CloverProfileSectionState();
}

class _CloverProfileSectionState extends State<CloverProfileSection> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder:
          (context, auth, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '나의 클로버',
                style: TextStyle(
                  color: AppColors.darkGray,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.thumb_up, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.profile.badgeName}',
                    style: TextStyle(color: AppColors.darkGray, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightGray,
                ),
                child: InkWell(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 90,
                    );

                    if (image != null && mounted) {
                      try {
                        final userService = Provider.of<UserService>(
                          context,
                          listen: false,
                        );
                        await userService.uploadProfileImage(
                          widget.profile.memberId.toString(),
                          image.path,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('프로필 사진이 업데이트되었습니다.')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('프로필 사진 업데이트 실패: $e')),
                          );
                        }
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(90),
                  child: ClipOval(
                    child: Image.network(
                      widget.profile.profileUrl ?? '',
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/logo.png',
                          width: 180,
                          height: 180,
                          fit: BoxFit.contain,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.profile.nickname,
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap:
                    widget.profile.localAuth
                        ? null
                        : () async {
                          final bool? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => UserAuthorizationScreen(
                                    memberId:
                                        widget.profile.memberId.toString(),
                                  ),
                            ),
                          );

                          if (result == true && mounted) {
                            auth.updateState(authorized: true);
                          }
                        },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color:
                        widget.profile.localAuth
                            ? AppColors.verylightGray.withOpacity(0.1)
                            : AppColors.verylightGray,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          widget.profile.localAuth
                              ? AppColors.primary
                              : AppColors.mediumGray,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color:
                            widget.profile.localAuth
                                ? AppColors.primary
                                : AppColors.mediumGray,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.profile.localAuth
                            ? '${widget.profile.localRegion} 현지인!'
                            : '현지인 인증 하실래요?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              widget.profile.localAuth
                                  ? AppColors.primary
                                  : AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
