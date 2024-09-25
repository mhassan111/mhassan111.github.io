
import 'package:file_saver/file_saver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';
import '../constants/controllers.dart';
import '../helpers/authentication.dart';
import '../repository/firebase_repository.dart';
import '../routing/app_pages.dart';
import '../utils/utils.dart';

class FirebaseController extends GetxController {
  static FirebaseController instance = Get.find();
  final _firebaseRepository = FirebaseRepository();
  late Rx<User?> firebaseUser;
  RxBool loading = false.obs;

  bool isLoading() => loading.value == true;

  @override
  void onReady() {
    firebaseUser = Rx<User?>(auth.currentUser);
    firebaseUser.bindStream(auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user != null) {
      menuController.changeActiveItemTo(AppRoutes.recordDisplayName);
      Get.offAllNamed(AppRoutes.homeRoute);
    } else {
      if (kDebugMode) {
        print('auth: user is null');
      }
    }
  }

  void signInWithEmailPassword(String email, String password) async {
    loading.value = true;
    return _firebaseRepository
        .signInWithEmailPassword(email, password)
        .then((value) {
      loading.value = false;
      Utils.showCustomSnackBar(Get.context, value);
    }).onError((error, stackTrace) {
      loading.value = false;
      Utils.showCustomSnackBar(Get.context, error.toString(),
          backgroundColor: Colors.redAccent);
    });
  }

  void registerUser(String userName, String email, String password) async {
    loading.value = true;
    return _firebaseRepository
        .registerUser(userName, email, password)
        .then((value) {
      loading.value = false;
      Utils.showCustomSnackBar(Get.context, value);
    }).onError((error, stackTrace) {
      loading.value = false;
      Utils.showCustomSnackBar(Get.context, error.toString(),
          backgroundColor: Colors.redAccent);
    });
  }

  void uploadFile(String path) {
    loading.value = true;
    _firebaseRepository.uploadFile(path).then((value) {
      loading.value = false;
      var imageUrl = value.first as String;
      var fileBytes = value.last as Uint8List;
      Utils.printMessage("uploaded file url = $imageUrl");
      if (fileBytes.isNotEmpty) {
        saveFile(fileBytes);
      } else {}
    });
  }

  void saveFile(Uint8List fileBytes) async {
    String? path = await FileSaver.instance.saveFile(
      name: "${DateTime.now()}",
      bytes: fileBytes,
      ext: 'mp3',
      mimeType: MimeType.mp3,
    );
    Utils.printMessage("saved file path = $path");
  }
}
