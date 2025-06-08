import 'package:x51/auth/presentation/screens/auth_screen.dart';

import '../routing/menu_items.dart';
import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import '../layout.dart';

abstract class AppPages {
  static const initialPage = AppRoutes.authenticationPageRoute;

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.homeRoute,
      page: () => SiteLayout(),
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.authenticationPageRoute,
      page: () => const AuthScreen(),
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      transition: Transition.fadeIn
    ),
  ];
}

abstract class AppRoutes {
  static const homeRoute = "/home";
  static const recordDisplayName = "Ambient Recording";
  static const recordPageRoute = "/ambientRecording";
  static const myRecordingsDisplayName = "Organizations";
  static const organizationsPageRoute = "/organizations";
  static const usersPageDisplayName = "Users";
  static const usersPageRoute = "/users";
  static const transcriptsName = "Transcripts";
  static const transcriptsRoute = "/transcripts";
  static const adminUserRightDisplayName = "Admin User Rights";
  static const adminUserRight = "/adminUserRights";
  static const authenticationDisplayName = "Log Out";
  static const authenticationPageRoute = "/auth";
}
