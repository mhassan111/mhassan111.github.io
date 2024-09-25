import 'dart:io' as io;
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firabase_storage;
import '../constants/constants.dart';
import '../helpers/authentication.dart';
import '../models/user_model.dart';
import '../utils/utils.dart';

class FirebaseRepository {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<String> registerUser(
      String userName, String email, String password) async {
    var result = '';
    try {
      var createUserResult =
          await createUserWithEmailPassword(userName, email, password);
      result = createUserResult.first as String;
      if (result.isEmpty || result != Constants.registerOk) {
        return result;
      }

      UserModel? userModel = createUserResult.last as UserModel?;
      if (userModel != null) {
        var userResult = await setUser(userModel);
        if (userResult.isNotEmpty) {
          result = Constants.registerOk;
        }
      }
    } catch (e) {
      Utils.printMessage('registerUser error = ${e.toString()}');
      return e.toString();
    }
    return result;
  }

  Future<List<dynamic>> createUserWithEmailPassword(
      String userName, String email, String password) async {
    String result = '';
    UserModel? userModel;
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        uid = user.uid;
        userEmail = user.email;
        userModel = UserModel(
            uuid: user.uid,
            username: userName,
            email: email,
            password: password,
            isAdmin: false);
      }
      result = Constants.registerOk;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        result = 'The password provided is too weak.';
        Utils.printMessage('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        result = 'The account already exists for that email.';
        Utils.printMessage('The account already exists for that email.');
      }
    } catch (e) {
      result = e.toString();
      Utils.printMessage('Something went wrong ${e.toString()}');
    }
    return [result, userModel];
  }

  Future<String> setUser(UserModel userModel) async {
    var result = '';
    try {
      await _firestore
          .collection('users')
          .doc(userModel.uuid)
          .set(userModel.toMap())
          .then((value) {
        Utils.printMessage('setUser success');
        result = 'Success';
      }).onError((e, stacktrace) {
        result = '';
      });
    } on Exception catch (e) {
      Utils.printMessage('setUser ${e.toString()}');
      result = '';
    }
    return result;
  }

  Future<String> signInWithEmailPassword(String email, String password) async {
    var result = "";
    User? user;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
      if (user != null) {
        result = Constants.registerOk;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        result = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        result = 'Wrong password provided for that user.';
      }
    } on Exception catch (e) {
      result = 'Error: ${e.toString()}';
    }
    return result;
  }

  Future<List<dynamic>> uploadFile(String path) async {
    String imageUrl = '';
    Uint8List fileBytes = Uint8List(0);

    try {
      firabase_storage.UploadTask uploadTask;
      firabase_storage.Reference ref = firabase_storage.FirebaseStorage.instance
          .ref()
          .child('${DateTime.now()}.mp3');

      final metadata =
          firabase_storage.SettableMetadata(contentType: 'audio/mp3');
      Uri blobUri = Uri.parse(html.window.sessionStorage[path]!);
      http.Response response = await http.get(blobUri);
      fileBytes = response.bodyBytes;
      uploadTask = ref.putData(fileBytes, metadata);

      await uploadTask.whenComplete(() => null);
      imageUrl = await ref.getDownloadURL();
    } catch (e) {
      print(e);
    }
    return [imageUrl, fileBytes];
  }
}
