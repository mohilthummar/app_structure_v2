import 'package:app_structure/data/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils {
  static void showToast({required String message}) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
      textColor: Colors.white,
      backgroundColor: AppColors.primaryColor, //
    );
  }
}
