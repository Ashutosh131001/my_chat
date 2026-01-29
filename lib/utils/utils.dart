import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

enum SnackbarType { success, error, info, warning }

class Utils {
  static void showsnackbar({
    required String message,
    String? title,
    SnackbarType type = SnackbarType.info,
  }) {
    Color bgcolor;
    IconData icon;
    switch (type) {
      case SnackbarType.success:
        bgcolor = Colors.green;
        icon = Icons.check_circle;
        title ??= "Success";
        break;

      case SnackbarType.error:
        bgcolor = Colors.redAccent;
        icon = Icons.error;
        title ??= "Error";
        break;

      case SnackbarType.info:
        bgcolor = Colors.lightBlue;
        icon = Icons.info;
        title ??= "Info";
        break;
      case SnackbarType.warning:
        bgcolor = Colors.orange;
        icon = Icons.warning;
        title ??= "Warning";
        break;
    }
    Get.snackbar(title,message,
    backgroundColor: bgcolor,
    colorText: Colors.white,
    snackPosition: SnackPosition.TOP,
    borderRadius: 16,
    margin: const EdgeInsets.all(16),
    icon: Icon(icon,color: Colors.white,),
    duration: const Duration(seconds: 3) 


    );
  }
}
