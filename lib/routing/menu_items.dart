import 'package:x51/constants/constants.dart';
import 'package:x51/helpers/shared_preferences_helper.dart';
import 'package:x51/models/user_model.dart';

import '../routing/app_pages.dart';

class MenuItem {
  final String name;
  final String route;

  MenuItem({required this.name, required this.route});
}

List<MenuItem> sideMenuItems = [
  MenuItem(name: AppRoutes.recordDisplayName, route: AppRoutes.recordPageRoute),
  MenuItem(
      name: AppRoutes.myRecordingsDisplayName,
      route: AppRoutes.organizationsPageRoute),
  MenuItem(
      name: AppRoutes.usersPageDisplayName, route: AppRoutes.usersPageRoute),
  MenuItem(name: AppRoutes.transcriptsName, route: AppRoutes.transcriptsRoute),
  // MenuItem(
  //     name: AppRoutes.adminUserRightDisplayName,
  //     route: AppRoutes.adminUserRight),
  MenuItem(
      name: AppRoutes.authenticationDisplayName,
      route: AppRoutes.authenticationPageRoute),
];

List<MenuItem> getSideMenuItems(UserModel userModel) {
  List<MenuItem> menuItems = [];
  menuItems.clear();
  menuItems.addAll(sideMenuItems);
  if (userModel.role == UserRole.orgUser.name) {
    menuItems.removeWhere(
        (element) => element.name == AppRoutes.myRecordingsDisplayName);
    // menuItems
    //     .removeWhere((element) => element.name == AppRoutes.transcriptsName);
  }

  // if (userModel.role != UserRole.superAdmin.name) {
  //   menuItems
  //       .removeWhere((element) => element.name == AppRoutes.adminUserRight);
  // }

  return menuItems;
}
