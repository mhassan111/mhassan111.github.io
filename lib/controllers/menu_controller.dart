import '../constants/style.dart';
import '../routing/app_pages.dart';
import '../routing/menu_items.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuController extends GetxController {
  static MenuController instance = Get.find();
  var activeItem = AppRoutes.recordDisplayName.obs;
  var hoverItem = ''.obs;

  changeActiveItemTo(String itemName) {
    activeItem.value = itemName;
  }

  onHover(String itemName) {
    if (!isActive(itemName)) hoverItem.value = itemName;
  }

  bool isActive(String itemName) => activeItem.value == itemName;
  bool isHovering(String itemName) => hoverItem.value == itemName;

  Widget returnIconFor(String itemName) {
    switch (itemName) {
      case AppRoutes.recordDisplayName:
        return customIcon(Icons.mic, itemName);
      case AppRoutes.myRecordingsDisplayName:
        return customIcon(Icons.place_rounded, itemName);
      case AppRoutes.usersPageDisplayName:
        return customIcon(Icons.person, itemName);
      case AppRoutes.authenticationDisplayName:
        return customIcon(Icons.login, itemName);
      default:
        return customIcon(Icons.exit_to_app, itemName);
    }
  }

  Widget customIcon(IconData icon, String itemName) {
    if (isActive(itemName)) return Icon(icon, size: 22, color: dark);
    return Icon(icon, size: 22, color: isHovering(itemName) ? dark : lightGray);
  }
}
