
import '../constants/constants.dart';
import '../controllers/firebase_controller.dart';
import '../controllers/menu_controller.dart';
import '../controllers/navigation_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../constants/controllers.dart';
import '../helpers/authentication.dart';
import '../routing/app_pages.dart';
import '../routing/menu_items.dart';

class AuthController extends GetxController {

  static AuthController authInstance = Get.find();
  late Rx<User?> firebaseUser;

  @override
  void onReady() {
    super.onReady();
    firebaseUser = Rx<User?>(auth.currentUser);
    firebaseUser.bindStream(auth.userChanges());

    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user != null) {
      if (kDebugMode) {
        print("auth user logged in = ${user.email}");
      }
      // user is logged in
      // Get.offAll(() => const Home());
      menuController.changeActiveItemTo(AppRoutes.recordDisplayName);
      Get.offAllNamed(AppRoutes.homeRoute);
    } else {
      if (kDebugMode) {
        print('auth: user is null');
      }
      Get.offAllNamed(AppRoutes.authenticationPageRoute);
    }
  }

  Future<String> register(String email, String password) async {
    // try {
    //   await auth.createUserWithEmailAndPassword(email: email, password: password);
    // } on FirebaseAuthException catch (e) {
    //   // this is solely for the Firebase Auth Exception
    //   // for example : password did not match
    //   print(e.message);
    //   // Get.snackbar("Error", e.message!);
    //   Get.snackbar(
    //     "Error",
    //     e.message!,
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    // } catch (e) {
    //   // this is temporary. you can handle different kinds of activities
    //   //such as dialogue to indicate what's wrong
    //   print(e.toString());
    //   Get.snackbar(
    //     "Error",
    //     "Unknown Error",
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    // }

    User? user;
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
      if (user != null) {
        uid = user.uid;
        userEmail = user.email;
        return Constants.registerOk;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
    } catch (e) {
      return 'Something went wrong';
    }

    return "Unknown Error";
  }

  void login(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // this is solely for the Firebase Auth Exception
      // for example : password did not match
      print(e.message);
    } catch (e) {
      print(e.toString());
    }
  }

  void signOut() {
    try {
      auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
