import 'package:flutter/material.dart';
import 'package:x51/auth/presentation/screens/auth_screen.dart';
import 'package:x51/pages/organizations/organizations_list.dart';
import 'package:x51/pages/quill/QuillEditorExample.dart';
import 'package:x51/pages/settings/admin_users_page.dart';
import '../pages/record/ambient_recorder.dart';
import '../pages/transcripts/TranscriptPage.dart';
import '../pages/users/users_page.dart';
import '../routing/app_pages.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.recordPageRoute:
      return getPageRoute(AmbientRecorder(onStop: (String path) {  },));
    case AppRoutes.organizationsPageRoute:
      return getPageRoute(const OrganizationsPage());
    case AppRoutes.usersPageRoute:
      return getPageRoute(const UsersPage());
    case AppRoutes.transcriptsRoute:
      return getPageRoute(const TranscriptPage());
    case AppRoutes.authenticationPageRoute:
      return getPageRoute(const AuthScreen());
      case AppRoutes.adminUserRight:
      return getPageRoute(const AdminUsersPage());
    default:
      return getPageRoute(AmbientRecorder(onStop: (String path) {  },));
  }
}

PageRoute getPageRoute(Widget child) {
  return MaterialPageRoute(builder: (context) => child);
}
