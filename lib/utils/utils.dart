import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../res/colors/app_color.dart';

class Utils {
  static void fieldFocusChange(
      BuildContext context, FocusNode current, FocusNode nextFocus) {
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static toastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColor.blackColor,
      textColor: AppColor.whiteColor,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  static toastMessageCenter(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColor.blackColor,
      gravity: ToastGravity.CENTER,
      toastLength: Toast.LENGTH_LONG,
      textColor: AppColor.whiteColor,
    );
  }

  static snackBar(String title, String message) {
    Get.snackbar(title, message);
  }

  static showSuccessSnackBar(String message) {
    Utils.showCustomSnackBar(Get.context, message);
  }

  static showErrorSnackBar(String message) {
    Utils.showCustomSnackBar(Get.context, message, backgroundColor: Colors.red);
  }

  static showCustomSnackBar(BuildContext? context, String message,
      {MaterialColor backgroundColor = Colors.green}) {
    var snackBar = SnackBar(
        width: 500,
        padding: const EdgeInsets.all(10),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        duration: const Duration(seconds: 3),
        dismissDirection: DismissDirection.horizontal,
        closeIconColor: Colors.white,
        backgroundColor: backgroundColor,
        content: Center(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ));
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  static printMessage(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
}
