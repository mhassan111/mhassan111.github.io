import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:x51/constants/constants.dart';
import 'package:x51/helpers/shared_preferences_helper.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isDarkTheme = false;
  bool _notificationsEnabled = true;
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load saved preferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() async {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _language = prefs.getString('language') ?? 'English';

      _firstNameController.text = await getStringPref(Constants.prefFirstName);
      _lastNameController.text = await getStringPref(Constants.prefLastName);
    });
  }

  // Save a preference
  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is String) {
      prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Your Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Handle save action
                    final firstName = _firstNameController.text;
                    final lastName = _lastNameController.text;
                    saveStringPref(Constants.prefFirstName, firstName);
                    saveStringPref(Constants.prefLastName, lastName);
                    // You can now save these values or perform any action
                    print('First Name: $firstName, Last Name: $lastName');
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ),
          // ListTile(
          //   title: Text('Dark Theme'),
          //   trailing: Switch(
          //     value: _isDarkTheme,
          //     onChanged: (value) {
          //       setState(() {
          //         _isDarkTheme = value;
          //         _savePreference('isDarkTheme', value);
          //       });
          //     },
          //   ),
          // ),
          // ListTile(
          //   title: Text('Enable Notifications'),
          //   trailing: Switch(
          //     value: _notificationsEnabled,
          //     onChanged: (value) {
          //       setState(() {
          //         _notificationsEnabled = value;
          //         _savePreference('notificationsEnabled', value);
          //       });
          //     },
          //   ),
          // ),
          // ListTile(
          //   title: Text('Language'),
          //   trailing: DropdownButton<String>(
          //     value: _language,
          //     onChanged: (value) {
          //       setState(() {
          //         _language = value!;
          //         _savePreference('language', value);
          //       });
          //     },
          //     items:
          //         <String>['English', 'Spanish', 'French'].map((String value) {
          //       return DropdownMenuItem<String>(
          //         value: value,
          //         child: Text(value),
          //       );
          //     }).toList(),
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
