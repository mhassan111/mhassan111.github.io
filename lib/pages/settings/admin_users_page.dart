import 'package:flutter/material.dart';
import 'package:x51/pages/settings/settings_users_list.dart';
import 'package:x51/pages/users/widgets/users_list.dart';

import '../../helpers/shared_preferences_helper.dart';
import '../../models/user_model.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<UserModel>(
          future: getUserModel(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Text('Loading....');
              default:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  var data = snapshot.data ?? '';
                  UserModel userModel = data as UserModel;
                  return Expanded(
                    child: ListView(
                      children: [AdminRightsUsersList(userModel: userModel)],
                    ),
                  );
                }
            }
          },
        ),
      ],
    );
  }
}
