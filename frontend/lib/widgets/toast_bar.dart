import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../config/theme.dart';

class ToastBar {
  static void clover(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColors.darkGray,
      textColor: AppColors.background,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
    );
  }
}
