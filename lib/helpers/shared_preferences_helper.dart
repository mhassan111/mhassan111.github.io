import 'package:shared_preferences/shared_preferences.dart';

Future<bool> saveStringPref(String key, String value) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  sp.setString(key, value);
  return true;
}

Future<String> getStringPref(String key) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  return sp.getString(key) != null ? sp.getString(key)! : "";
}
