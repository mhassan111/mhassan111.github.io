
import 'package:flutter/cupertino.dart';

import '../../helpers/shared_preferences_helper.dart';
import '../../models/user_model.dart';

Widget userModelFutureWidget(Widget widget) {
  return FutureBuilder<UserModel>(
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
            return widget;
          }
      }
    },
  );
}