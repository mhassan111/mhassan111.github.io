import 'package:file_saver/file_saver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:x51/constants/constants.dart';
import 'package:firebase_storage/firebase_storage.dart' as firabase_storage;
import 'package:x51/models/organization.dart';
import 'package:x51/models/storage_file.dart';
import '../constants/controllers.dart';
import '../helpers/shared_preferences_helper.dart';
import '../models/user_model.dart';
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
    // firebaseUser = Rx<User?>(FirebaseAuth.instance.currentUser);
    // firebaseUser.bindStream(FirebaseAuth.instance.userChanges());
    // ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user != null) {
      // menuController.changeActiveItemTo(AppRoutes.recordDisplayName);
      // Get.offAllNamed(AppRoutes.homeRoute);
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
      if (value.isNotEmpty) {
        Utils.showSuccessSnackBar(value);
        if (value == Constants.loginOk) {
          menuController.changeActiveItemTo(AppRoutes.recordDisplayName);
          Get.offAllNamed(AppRoutes.homeRoute);
        }
      } else {
        Utils.showErrorSnackBar("Error! Try Again");
      }
    }).onError((error, stackTrace) {
      loading.value = false;
      Utils.showErrorSnackBar(error.toString());
    });
  }

  void registerUser(String userName, String email, String password) async {
    loading.value = true;
    return _firebaseRepository
        .registerUser(userName, email, password)
        .then((value) {
      loading.value = false;
      if (value.isNotEmpty) {
        Utils.showSuccessSnackBar(value);
        if (value == Constants.registerOk) {
          // menuController.changeActiveItemTo(AppRoutes.recordDisplayName);
          // Get.offAllNamed(AppRoutes.homeRoute);
        }
      } else {
        Utils.showErrorSnackBar("Error! Try Again");
      }
    }).onError((error, stackTrace) {
      loading.value = false;
      Utils.showErrorSnackBar(error.toString());
    });
  }

  Future<StorageFile?> uploadFile(
      Organization org, String firstName, String lastName, String path) async {
    loading.value = true;
    return await _firebaseRepository
        .uploadFile(firstName, lastName, path)
        .then((value) {
      loading.value = false;
      var imageUrl = value.first as String;
      var fileBytes = value[1] as Uint8List;
      var filePath = value.last as String;
      StorageFile storageFile = StorageFile(
          name: filePath.replaceFirst(
              "gs://${firabase_storage.FirebaseStorage.instance.bucket}/", ""),
          downloadUrl: imageUrl,
          filePath: filePath);

      Utils.printMessage("uploaded file url = $imageUrl");
      if (fileBytes.isNotEmpty) {
        return storageFile;
      } else {
        return null;
      }
    });
  }

  void saveFile(Uint8List fileBytes) async {
    UserModel userModel = await getUserModel();
    String firstName = await getStringPref(Constants.prefFirstName);
    String lastName = await getStringPref(Constants.prefLastName);
    String fileName =
        '${firstName}_${lastName}_${DateTime.now()}_${userModel.email}_${userModel.orgName}_${userModel.locName}';

    String? path = await FileSaver.instance.saveFile(
      name: fileName,
      bytes: fileBytes,
      ext: 'mp3',
      mimeType: MimeType.mp3,
    );
    Utils.printMessage("saved file path = $path");
  }

  void signOut() {
    _firebaseRepository.signOut().then((result) {
      menuController.changeActiveItemTo(AppRoutes.recordDisplayName);
      Get.offAllNamed(AppRoutes.authenticationPageRoute);
      Utils.showSuccessSnackBar(result);
    }).onError((error, stackTrace) {
      Utils.showErrorSnackBar("Error: Signing Out");
    });
  }
}
