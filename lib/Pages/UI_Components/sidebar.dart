import 'package:ai_image/Pages/history_page.dart';
import 'package:ai_image/resources/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  void _getUserInfo() async {
    User? user = _auth.currentUser;
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Pallete.mainFontColor, // Change header color here
            ),
            accountName: Text(_user?.displayName ?? ''),
            accountEmail: Row(
              children: [
                Text(_user?.email.toString().split('@').first ?? ''),
                Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.logout,
                    color: Pallete.borderColor,
                  ),
                  onPressed: () async {
                    try {
                      await _auth.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    } catch (e) {
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
                    }
                  },
                ),
              ],
            ),
            currentAccountPicture: CircleAvatar(
              child: Text(_user?.email?.substring(0, 1) ?? ''),
            ),
          ),
          FutureBuilder<QuerySnapshot>(
            future: _getChatPrompts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return ListTile(
                  title: Text('No Chats'),
                );
              } else {
                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    String prompt = doc['prompt'] ?? '';
                    String imageUrl = doc['content'] ?? '';
                    // Trim the prompt to 10 words
                    if (prompt.split(' ').length > 10) {
                      prompt =
                          prompt.split(' ').sublist(0, 10).join(' ') + '...';
                    }
                    return Container(
                      padding: EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(16.0),
                          color: Colors.white70),
                      child: ListTile(
                        title: Text(
                          prompt,
                        ),
                        onTap: () {
                          // Handle tapping on a chat prompt
                          Get.to(
                              HistoryPage(title: prompt, imageUrl: imageUrl));
                          // Navigator.pop(context); // Close drawer
                          // Implement your logic to show the selected chat prompt
                        },
                      ),
                    );
                  }).toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<QuerySnapshot> _getChatPrompts() async {
    return await _firestore
        .collection('users')
        .doc(_user?.uid)
        .collection('chat')
        .get();
  }
}
