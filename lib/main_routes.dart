import 'package:ai_image/Auth/forget.dart';
import 'package:ai_image/Auth/login.dart';
import 'package:ai_image/Auth/signup.dart';
import 'package:ai_image/Pages/home_page.dart';
import 'package:ai_image/Pages/welcome.dart';
import 'package:flutter/cupertino.dart';

class MainRoutes {
  // ignore: non_constant_identifier_names
  Map<String, Widget Function(BuildContext)> Routes = {
    '/': (context) => const WelcomePage(),
    LoginView.route: (context) => LoginView(),
    HomePage.route:(context)=> const HomePage(),
    // HistoryPage.route:(context)=> HistoryPage(),.
    SignUpView.route: (context) => SignUpView(),
    ForgetPassView.route: (context) => const ForgetPassView(),
  };
}
