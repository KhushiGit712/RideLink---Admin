import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ridelink_admin/firebase_options.dart';
import 'package:ridelink_admin/routes/routes.dart';

import 'core/utils/stretch_scroll_behavior.dart';
import 'core/utils/utils.dart';
import 'routes/routes_name.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Utils.darkStatusBar();
  await Utils.screenPortrait();
  Utils.hideKeyboard();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ride Link',
      themeMode: ThemeMode.light,
      getPages: pages,
      initialRoute: AppRoutes.splashView,
      scrollBehavior: ScrollBehaviorModified(),
      builder: (context, child) => child!,
    );
  }
}
