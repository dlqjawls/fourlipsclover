import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'edit_widgets/profile_image_section.dart';
import '../../models/user_model.dart';

class UserEditScreen extends StatefulWidget {
  final UserProfile profile;

  const UserEditScreen({super.key, required this.profile});

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verylightGray,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.verylightGray,
        title: const Text('나의 정보 수정'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileImageSection(
              userId: widget.profile.memberId.toString(),
              initialImageUrl: widget.profile.profileUrl,
            ),
          ],
        ),
      ),
    );
  }
}
