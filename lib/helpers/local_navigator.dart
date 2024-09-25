import '../constants/controllers.dart';
import '../routing/app_pages.dart';
import '../routing/router.dart';
import '../routing/menu_items.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Navigator localNavigator() => Navigator(
      key: navigationController.navigatorKey,
      initialRoute: AppRoutes.recordPageRoute,
      onGenerateRoute: generateRoute
);