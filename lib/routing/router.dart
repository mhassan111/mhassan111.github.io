import '../pages/products/products.dart';
import '../routing/app_pages.dart';
import '../routing/menu_items.dart';
import 'package:flutter/material.dart';
import '../pages/authentication/authentication.dart';
import '../pages/record/recorder.dart';
import '../pages/record/ambient_recorder.dart';
import '../pages/users/users.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.recordPageRoute:
      return getPageRoute(AmbientRecorder(onStop: (String path) {  },));
    case AppRoutes.recordingsPageRoute:
      return getPageRoute(const ProductsPage());
    case AppRoutes.usersPageRoute:
      return getPageRoute(const UsersPage());
    case AppRoutes.authenticationPageRoute:
      return getPageRoute(const AuthenticationPage());
    default:
      return getPageRoute(AmbientRecorder(onStop: (String path) {  },));
  }
}

PageRoute getPageRoute(Widget child) {
  return MaterialPageRoute(builder: (context) => child);
}
