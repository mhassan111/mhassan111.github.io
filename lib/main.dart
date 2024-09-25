import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:x51/repository/firebase_repository.dart';

import 'constants/style.dart';
import 'controllers/firebase_controller.dart';
import 'controllers/menu_controller.dart' as menu_controller;
import 'controllers/navigation_controller.dart';
import 'firebase_options.dart';
import 'pages/404/error_page.dart';
import 'routing/app_pages.dart';

final _firebaseRepository = FirebaseRepository();

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  var app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  Get.put(NavigationController());
  Get.put(menu_controller.MenuController());
  Get.put(FirebaseController());
  startUploadChecker();
  runApp(const ProviderScope(child: MyApp()));
}

void startUploadChecker() {
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    await _firebaseRepository.uploadPendingFiles();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        scrollBehavior: MyCustomScrollBehavior(),
        initialRoute: AppPages.initialPage,
        unknownRoute:
            GetPage(name: '/not-found', page: () => const PageNotFound()),
        defaultTransition: Transition.leftToRight,
        getPages: AppPages.pages,
        debugShowCheckedModeBanner: false,
        title: "X51",
        theme: ThemeData(
            scaffoldBackgroundColor: light,
            textTheme: GoogleFonts.mulishTextTheme(
              Theme.of(context).textTheme,
            ).apply(
              bodyColor: Colors.black,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
              },
            ),
            primarySwatch: Colors.indigo));
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
