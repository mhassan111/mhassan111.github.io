import '../routing/app_pages.dart';

class MenuItem {
  final String name;
  final String route;

  MenuItem({required this.name, required this.route});
}

List<MenuItem> sideMenuItems = [
  MenuItem(name: AppRoutes.recordDisplayName, route: AppRoutes.recordPageRoute),
  MenuItem(name: AppRoutes.myRecordingsDisplayName, route: AppRoutes.recordingsPageRoute),
  MenuItem(name: AppRoutes.usersPageDisplayName, route: AppRoutes.usersPageRoute),
  MenuItem(name: AppRoutes.authenticationDisplayName, route: AppRoutes.authenticationPageRoute),
];
