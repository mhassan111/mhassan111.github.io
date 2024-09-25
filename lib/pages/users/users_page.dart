//import 'constants/controllers.dart';
//import 'helpers/responsiveness.dart';
//import 'widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:x51/pages/users/widgets/users_list.dart';

import '../../helpers/shared_preferences_helper.dart';
import '../../models/user_model.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
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
                      children: [UsersList(userModel: userModel)],
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
