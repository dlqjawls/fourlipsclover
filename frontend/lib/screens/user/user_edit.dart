import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/screens/user/edit_widgets/profile_image_section.dart';
import 'package:frontend/screens/user/edit_widgets/info_tile.dart';

class UserEditScreen extends StatefulWidget {
  const UserEditScreen({super.key});

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verylightGray,
      appBar: AppBar(
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
            const ProfileImageSection(),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: const [
                  InfoTile(label: '주소 변경', info: '광주 싸피 어딘가'),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
