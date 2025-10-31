import 'package:Sleephoria/main.dart';
import 'package:Sleephoria/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Sleephoria/custom/custom_setting.dart';
import 'package:Sleephoria/custom/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({super.key});

  @override
  MyAccountPageState createState() => MyAccountPageState();
}

class MyAccountPageState extends State<MyAccountPage> {
  bool _isDarkMode = false;
  String fullName = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _loadCachedUserInfo();
    _loadUserInfoFromFirestore();
    final appState = MyApp.of(context);
    if (appState != null) _isDarkMode = appState.isDarkMode;
  }

  Future<void> _loadCachedUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      fullName = user?.displayName ?? prefs.getString('fullName') ?? 'No Name';
      email = user?.email ?? prefs.getString('email') ?? 'No Email';
    });
  }

  Future<void> _loadUserInfoFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final fetchedName = data?['fullName'];

        if (fetchedName != null &&
            fetchedName.isNotEmpty &&
            fetchedName != fullName) {
          setState(() {
            fullName = fetchedName;
          });

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('fullName', fetchedName);
          await prefs.setString('email', user.email ?? 'No Email');
        }
      }
    } catch (e) {
      debugPrint("Error fetching user details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.backgroundColor(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'My Account',
          style: TextStyle(
            color: ThemeHelper.appBarTitle(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              labelText: 'Full Name',
              initialValue: fullName,
              readOnly: true,
            ),
            SizedBox(height: 16.0),
            CustomTextField(
              labelText: 'Email',
              initialValue: email,
              readOnly: true,
            ),
            SizedBox(height: 10.0),
            Divider(),
            CustomSetting(
              title: 'App Settings',
              switchLabel: 'Dark Mode',
              switchValue: _isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _isDarkMode = value;
                });
                final appState = MyApp.of(context);
                appState?.toggleTheme(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
