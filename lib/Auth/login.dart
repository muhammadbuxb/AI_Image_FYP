import 'package:ai_image/Auth/forget.dart';
import 'package:ai_image/Auth/signup.dart';
import 'package:ai_image/resources/colors.dart';
import 'package:ai_image/resources/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_image/Pages/home_page.dart';

class LoginView extends StatefulWidget {
  static String route = '/login';
  LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewPage();
}

class _LoginViewPage extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
       
          await _auth
              .signInWithEmailAndPassword(
                email: emailController.text,
                password: passwordController.text,
              )
              .then((value) => {
                    Get.snackbar(
                      'Success',
                      'Account Login successfully',
                      backgroundColor: Colors.green,
                      snackPosition: SnackPosition.BOTTOM,
                      duration: Duration(seconds: 3),
                    )
                  });
          Get.off(HomePage());

          // Navigate to the home screen after successful login
         // Navigator.pushReplacementNamed(context, '/home');
      } on FirebaseAuthException catch (e) {
        print('Error logging in: ${e.code}');

        Get.defaultDialog(
          title: 'Error',
          middleText: '${e.code.toString()}',
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
        margin: EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 16.0),
        child: Form(
          key: _formKey,
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
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
                const Center(
                    child: Text('Login',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 30.0,
                            color: Pallete.mainFontColor))),
                // const SizedBox(height: 20),
                TextFormField(
                  validator: (Value) {
                    if (Value!.contains("@") &&
                        Value.contains(".") &&
                        Value.length >= 5) {
                      return null;
                    }
                    return "Invalid Email Type";
                  },
                  decoration: const InputDecoration(
                    labelText: "Email",
                  ),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  validator: (Value) {
                    if (Value!.length >= 8) {
                      return null;
                    }
                    return "Enter Password of 8 Digits";
                  },
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Get.to(ForgetPassView());
                  },
                  child: const Text(
                    "Forget Password",
                    style:
                        TextStyle(fontSize: 17, color: Pallete.mainFontColor),
                  ),
                ),
                const SizedBox(height: 25),

                FloatingActionButton.extended(
                  backgroundColor: Pallete.mainFontColor,
                  onPressed: _isLoading ? null : _login,
                  label: _isLoading
                      ? const CircularProgressIndicator(
                          backgroundColor: Colors.white)
                      : const Text(
                          'Login',
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
                    Get.to(SignUpView());
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text.rich(TextSpan(
                        text: "Didn't have an account?",
                        style: TextStyle(fontSize: 17),
                        children: [
                          TextSpan(
                            text: "  SignUp",
                            style: TextStyle(
                                color: Pallete.mainFontColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w700),
                          )
                        ])),
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
