import 'dart:async';
import 'package:ai_image/Auth/login.dart';
import 'package:ai_image/Pages/home_page.dart';
import 'package:ai_image/auth_check.dart';
import 'package:animate_do/animate_do.dart';
import 'package:ai_image/resources/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../resources/strings.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Get.to(()=>AuthCheck(),);
     
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: Get.height,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Pallete.firstSuggestionBoxColor,
                    Pallete.firstSuggestionBoxColor,
                    Pallete.secondSuggestionBoxColor,
                    Pallete.secondSuggestionBoxColor,
                  ],
                ),
              ),
            ),
            Positioned(
              left: Get.width / 4,
              top: Get.height / 4,
              child: FadeInLeft(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      StringUtils.logo,
                      height: Get.height/4,
                      // width: Get.width,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Ai Image',
                      style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w800,
                          color: Pallete.mainFontColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
