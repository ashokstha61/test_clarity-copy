import 'package:Sleephoria/theme.dart';
import 'package:Sleephoria/view/home/homepage.dart';
import 'package:Sleephoria/view/signin/sign_in_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Sleephoria/view/login/auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../custom/custom_login_button.dart';
import '../profile/DeleteAccount/dialog_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      User? user = await _authService.signInWithGoogle(context);
      if (!mounted) return;

      if (user != null) {
        final db = FirebaseFirestore.instance;
        final userRef = db.collection("users").doc(user.uid);

        // Fetch existing user data if any
        final doc = await userRef.get();
        final isDisabled = doc.data()?["isDisabled"];

        // ✅ Check if user account is disabled
        if (isDisabled ?? false) {
          showAlert(
            context,
            "Account Disabled",
            "Your account has been disabled. Please contact support.",
          );
          await FirebaseAuth.instance.signOut();
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login Successful'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // ✅ Save or update user info in Firestore
        await userRef.set({
          "uid": user.uid,
          "email": user.email,
          "fullName": user.displayName ?? "",
          "phone": user.phoneNumber ?? "",
          "isDisabled": false,
          "createdAt": DateTime.timestamp(),
        }, SetOptions(merge: true));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
              (route) => false,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isUserLoggedIn', true);


      }
    } catch (e) {
      debugPrint("Google sign-in failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeHelper.backgroundColor(context),
      body:Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 60),
              SizedBox(
                height: 453.h,
                width : 339.w,
                child: Image.asset('assets/images/LoginPageImage.png'),
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CustomLoginButton(
                        label: 'Connect with Google',
                        imagePath: 'assets/images/google.png',
                        onPressed: _handleGoogleLogin,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: CustomLoginButton(
                        label: 'Connect with Email',
                        imagePath: 'assets/images/mail.png',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignInScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
