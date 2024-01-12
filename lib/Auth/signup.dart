import 'package:ai_image/Auth/login.dart';
import 'package:ai_image/Pages/home_page.dart';
import 'package:ai_image/resources/colors.dart';
import 'package:ai_image/resources/strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpView extends StatefulWidget {
  static String route = '/signup';
  SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewPage();
}

class _SignUpViewPage extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passController.text.trim(),
        );

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': nameController.text.trim(),
          'email': emailController.text.trim(),
          'uid': userCredential.user!.uid,
        });

        Get.snackbar(
          'Success',
          'Account created successfully',
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
        Get.off(HomePage());

        // Navigate to the next screen or perform any other action after successful registration
        // For example, you can navigate to the home screen:
        // Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        print('Error creating account: $e');

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
        margin: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 16.0),
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
                    child: Text('SignUp',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 24.0,
                            color: Pallete.mainFontColor))),
                TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Name";
                      }
                      return null;
                    },
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Full Name")),
                const SizedBox(height: 10),
                TextFormField(
                  validator: (Value) {
                    if (Value!.contains("@") &&
                        Value.contains(".") &&
                        Value.length >= 5) {
                      return null;
                    }
                    return "Invalid Email Type";
                  },
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                  ),
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty && value.length <= 8) {
                      return "Enter Password of 8 Digits ";
                    }
                    return null;
                  },
                  controller: passController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Password"),
                ),
                const SizedBox(height: 20),
                FloatingActionButton.extended(
                  onPressed: _isLoading ? null : _createAccount,
                  backgroundColor: Pallete.mainFontColor,
                  label: _isLoading
                      ? Text('Creating Account...',
                          style: TextStyle(color: Colors.white))
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    Get.off(LoginView());
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text.rich(TextSpan(
                        text: "Already have an account ?",
                        style: TextStyle(fontSize: 16),
                        children: [
                          TextSpan(
                            text: "  Login",
                            style: TextStyle(
                                color: Pallete.mainFontColor,
                                fontSize: 20,
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
