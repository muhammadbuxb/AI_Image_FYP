import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_image/Auth/login.dart';
import 'package:ai_image/resources/strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../resources/colors.dart';

class ForgetPassView extends StatefulWidget {
  static String route = '/forget';
  const ForgetPassView({super.key});

  @override
  State<ForgetPassView> createState() => _ForgetPassViewPage();
}

class _ForgetPassViewPage extends State<ForgetPassView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        await _auth.sendPasswordResetEmail(
          email: emailController.text.trim(),
        );

        // Show success message
        Get.snackbar(
          'Email Sent',
          'Password reset email sent successfully. Check your inbox.',
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
      } catch (e) {
        print('Error sending reset email: $e');

        // Show error dialog
        Get.defaultDialog(
          title: 'Error',
          middleText: e.toString(),
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back(); // Close the dialog
          },
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: Get.width,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.fromLTRB(16.0, 70.0, 16.0, 16.0),
        child: Form(
          key: _formKey,
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(20),
            child: ListView(
              shrinkWrap: true,
              children: [
                Hero(
                  tag: 'logo',
                  child: Image.asset(
                    StringUtils.logo,
                    width: Get.width * .2,
                    height: Get.height * .2,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                const Center(
                  child: Text(
                    'Forget Password',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 24.0,
                      color: Pallete.mainFontColor,
                    ),
                  ),
                ),
                TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (value!.contains("@") &&
                        value.contains(".") &&
                        value.length >= 5) {
                      return null;
                    }
                    return "Invalid Email Type";
                  },
                  decoration: const InputDecoration(
                    labelText: "Email",
                  ),
                ),
                const SizedBox(height: 25),
                FloatingActionButton.extended(
                  onPressed: _isLoading ? null : _sendResetEmail,
                  backgroundColor: Pallete.mainFontColor,
                  label: _isLoading
                      ? Text(
                          'Sending Email...',
                          style: TextStyle(color: Colors.white),
                        )
                      : const Text(
                          "Send Mail",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () async {
                    Get.off(LoginView());
                  },
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text.rich(TextSpan(
                          text: "Back to ",
                          style: TextStyle(fontSize: 18),
                          children: [
                            TextSpan(
                              text: "  Login ",
                              style: TextStyle(
                                color: Pallete.mainFontColor,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          ]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
