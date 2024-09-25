import 'package:flutter/material.dart';
import 'package:x51/helpers/shared_preferences_helper.dart';
import 'package:x51/models/user_model.dart';
import 'package:x51/pages/settings/settings_screen.dart';

import '../../constants/style.dart';
import '../../helpers/responsiveness.dart';
import 'custom_text.dart';

FutureBuilder categoryText = FutureBuilder<UserModel>(
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
          return Text(userModel.email);
        }
    }
  },
);

AppBar topNavigationBar(BuildContext context, GlobalKey<ScaffoldState> key) =>
    AppBar(
      title: Row(
        children: [
          Visibility(
              visible: !ResponsiveWidget.isSmallScreen(context),
              child: CustomText(
                text: "X51",
                color: lightGray,
                size: 20,
                weight: FontWeight.bold,
              )),
          Expanded(child: Container()),
          Row(children: [
            // IconButton(
            //     icon: Icon(
            //       Icons.settings,
            //       color: dark,
            //     ),
            //     onPressed: () {
            //       // _showSettingScreen(context);
            //     }),
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
                      return Text(userModel.email, style: const TextStyle(
                        fontSize: 15
                      ),);
                    }
                }
              },
            )
          ])
          // Stack(
          //   children: [
          //     IconButton(
          //         icon: Icon(
          //           Icons.notifications,
          //           color: dark.withOpacity(.7),
          //         ),
          //         onPressed: () {}),
          //     Positioned(
          //       top: 7,
          //       right: 7,
          //       child: Container(
          //         width: 12,
          //         height: 12,
          //         padding: const EdgeInsets.all(4),
          //         decoration: BoxDecoration(
          //             color: active,
          //             borderRadius: BorderRadius.circular(30),
          //             border: Border.all(color: light, width: 2)),
          //       ),
          //     )
          //   ],
          // ),
          // Container(
          //   width: 1,
          //   height: 22,
          //   color: lightGray,
          // ),
          // const SizedBox(
          //   width: 24,
          // ),
          // if (!ResponsiveWidget.isSmallScreen(context))
          //   Obx(() => CustomText(
          //         text: _loggedUserController.loggedUser.name ?? "User Name",
          //         color: lightGray,
          //       )),
          // const SizedBox(
          //   width: 16,
          // ),
          // Container(
          //   decoration: BoxDecoration(
          //       color: active.withOpacity(.5),
          //       borderRadius: BorderRadius.circular(30)),
          //   child: Container(
          //       decoration: BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: BorderRadius.circular(30)),
          //       padding: const EdgeInsets.all(2),
          //       margin: const EdgeInsets.all(2),
          //       child: Obx(() => CircleAvatar(
          //           backgroundColor: light,
          //           child: _loggedUserController.loggedUser.imageUrl == null
          //               ? Icon(
          //                   Icons.person_outline,
          //                   color: dark,
          //                 )
          //               : ImageNetwork(
          //                   image: _loggedUserController.loggedUser.imageUrl!,
          //                   width: 40,
          //                   height: 40,
          //                   borderRadius: BorderRadius.circular(70),
          //                   onLoading: const Center(
          //                     child: CircularProgressIndicator(),
          //                   ),
          //                 )))),
          // ),
        ],
      ),
      iconTheme: IconThemeData(color: dark),
      elevation: 0,
      backgroundColor: Colors.transparent,
    );

void _showSettingScreen(
    BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (BuildContext context) {
      return SettingsScreen();
    },
  ));
}

