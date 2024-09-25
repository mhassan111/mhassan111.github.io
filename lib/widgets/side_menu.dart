import '../../constants/constants.dart';
import '../../routing/app_pages.dart';
import 'package:flutter/material.dart';
import '../../constants/controllers.dart';
import '../../constants/style.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/side_menu_item.dart';
import 'package:get/get.dart';
import '../helpers/responsiveness.dart';
import '../helpers/shared_preferences_helper.dart';
import '../models/user_model.dart';
import '../routing/menu_items.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      color: light,
      child: ListView(
        children: [
          if (ResponsiveWidget.isSmallScreen(context))
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    SizedBox(width: width / 48),
                    // Padding(
                    //   padding: const EdgeInsets.only(right: 12),
                    //   child: Image.asset("assets/icons/logo.png"),
                    // ),
                    Flexible(
                      child: CustomText(
                        text: "X51",
                        size: 20,
                        weight: FontWeight.bold,
                        color: active,
                      ),
                    ),
                    SizedBox(width: width / 48),
                  ],
                ),
              ],
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<UserModel>(
                future: getUserModel(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Container();
                    default:
                      if (snapshot.hasError) {
                        return Container();
                      } else {
                        var data = snapshot.data ?? '';
                        UserModel userModel = data as UserModel;
                        return Column(
                          children: getSideMenuItems(userModel)
                              .map((item) => SideMenuItem(
                                  itemName: item.name ==
                                          AppRoutes.authenticationPageRoute
                                      ? "Log Out"
                                      : item.name,
                                  onTap: () {
                                    if (item.route ==
                                        AppRoutes.authenticationPageRoute) {
                                      firebaseController.signOut();
                                    }
                                    if (!menuController.isActive(item.name)) {
                                      menuController
                                          .changeActiveItemTo(item.name);
                                      if (ResponsiveWidget.isSmallScreen(
                                          context)) {
                                        Get.back();
                                      }
                                      navigationController
                                          .navigateTo(item.route);
                                    }
                                  }))
                              .toList(),
                        );
                      }
                  }
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
