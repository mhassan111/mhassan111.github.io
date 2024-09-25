import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:x51/constants/constants.dart';
import 'package:x51/models/user_model.dart';

// Save a single file path
Future<void> saveFilePath(String filePath) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  List<String> pendingFiles = sp.getStringList("pending_uploads") ?? [];

  if (!pendingFiles.contains(filePath)) {
    pendingFiles.add(filePath);
    await sp.setStringList("pending_uploads", pendingFiles);
  }
}

// Get all pending file paths
Future<List<String>> getPendingFilePaths() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  return sp.getStringList("pending_uploads") ?? [];
}

// Remove a file path after successful upload
Future<void> removeFilePath(String filePath) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  List<String> pendingFiles = sp.getStringList("pending_uploads") ?? [];

  pendingFiles.remove(filePath);
  await sp.setStringList("pending_uploads", pendingFiles);
}

Future<bool> saveStringPref(String key, String value) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  sp.setString(key, value);
  return true;
}

Future<String> getStringPref(String key) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  return sp.getString(key) != null ? sp.getString(key)! : "";
}

Future<bool> saveBoolPref(String key, bool value) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  sp.setBool(key, value);
  return true;
}

Future<bool> getBoolPref(String key) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  return sp.getBool(key) != null ? sp.getBool(key)! : false;
}

Future<bool> saveUserModel(UserModel userModel) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  Map<String, dynamic> user = userModel.toMap();
  return await pref.setString('userModel', jsonEncode(user));
}

Future<UserModel> getUserModel() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userPref = prefs.getString('userModel');
  if (userPref == null) {
    return UserModel.emptyUser();
  }
  Map<String, dynamic> userMap = jsonDecode(userPref) as Map<String, dynamic>;
  return UserModel.fromMap(userMap);
}

Future<void> clearSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
