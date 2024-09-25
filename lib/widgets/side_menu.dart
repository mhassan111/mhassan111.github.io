import '../../constants/constants.dart';
import '../../helpers/authentication.dart';
import '../../pages/authentication/authentication.dart';
import '../../routing/app_pages.dart';
import 'package:flutter/material.dart';
import '../../constants/controllers.dart';
import '../../constants/style.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/side_menu_item.dart';
import 'package:get/get.dart';
import '../helpers/responsiveness.dart';
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
                        text: "MedTranscript",
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
            children: sideMenuItems.map((item) => SideMenuItem(
              itemName: item.name == AppRoutes.authenticationPageRoute ? "Log Out" :
                        item.name,
              onTap: () {
                //remove the cookie
                CookieManager().removeCookie(Constants.cookieName);

                if (item.route == AppRoutes.authenticationPageRoute) {
                  signOutGoogle()
                  .then((result) => print(result))
                  .catchError((error) => print(error));
                  signOut().then((result) => {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                         width: 500,
                          padding: const EdgeInsets.all(10),
                          behavior: SnackBarBehavior.floating,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          duration: const Duration(seconds: 3),
                          dismissDirection: DismissDirection.horizontal,
                          closeIconColor: Colors.white,
                          backgroundColor: result == Constants.logoutOk ? 
                           Colors.green : Colors.redAccent,
                          content: const Center(
                            child: Text(
                              Constants.logoutOk,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                      )
                    )
                  }).catchError((error) => {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                         width: 500,
                          padding: EdgeInsets.all(10),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          duration: Duration(seconds: 3),
                          dismissDirection: DismissDirection.horizontal,
                          closeIconColor: Colors.white,
                          backgroundColor: Colors.redAccent,
                          content: Center(
                            child: Text(
                              Constants.logoutError,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                      )
                    )
                  });
                  menuController.changeActiveItemTo(AppRoutes.recordDisplayName);
                  Get.offAllNamed(AppRoutes.authenticationPageRoute);
                }
                if (!menuController.isActive(item.name)) {
                  menuController.changeActiveItemTo(item.name);
                  if (ResponsiveWidget.isSmallScreen(context)) {
                    Get.back();
                  }
                  navigationController.navigateTo(item.route);
                }
              })).toList(),
          )
        ],
      ),
    );
  }
}
