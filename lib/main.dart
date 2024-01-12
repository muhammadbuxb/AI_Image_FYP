import 'package:ai_image/main_routes.dart';
import 'package:ai_image/resources/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ai Image Generator',
      theme: AppThemes().lightTheme,
      defaultTransition: Transition.downToUp,
      // home:WelcomePage(),
      initialRoute: '/',
      transitionDuration: const Duration(seconds: 1),
      routes: MainRoutes().Routes,
    );
  }
}
