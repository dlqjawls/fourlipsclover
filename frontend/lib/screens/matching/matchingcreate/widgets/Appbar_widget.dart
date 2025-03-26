// AppBar 공통 스타일을 위한 Widget
import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

PreferredSize buildMatchingAppBar(BuildContext context, String title) {
  return PreferredSize(
    preferredSize: Size.fromHeight(56.0),
    child: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.darkGray,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    ),
  );
}
